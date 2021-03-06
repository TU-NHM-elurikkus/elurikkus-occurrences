package au.org.ala.biocache.hubs

import grails.converters.JSON
import grails.plugin.cache.CacheEvict
import grails.plugin.cache.Cacheable

import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method
import org.apache.commons.httpclient.HttpClient
import org.apache.commons.httpclient.methods.HeadMethod
import org.apache.commons.io.FileUtils
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.springframework.context.*
import org.springframework.web.client.RestClientException

import javax.annotation.PostConstruct

/**
 * Service to perform web service DAO operations
 */
class WebServicesService implements ApplicationContextAware {

    ApplicationContext applicationContext

    public static final String ENVIRONMENTAL = "Environmental"
    public static final String CONTEXTUAL = "Contextual"

    def grailsApplication, facetsCacheServiceBean

    String BIE_SERVICE_BACKEND_URL, BIOCACHE_SERVICE_BACKEND_URL, COLLECTORY_BACKEND_URL, LAYERS_SERVICE_BACKEND_URL, LOGGER_SERVICE_BACKEND_URL

    @PostConstruct
    def init() {
        BIE_SERVICE_BACKEND_URL = grailsApplication.config.bieService.internal.url
        BIOCACHE_SERVICE_BACKEND_URL = grailsApplication.config.biocacheService.internal.url
        COLLECTORY_BACKEND_URL = grailsApplication.config.collectory.internal.url
        LAYERS_SERVICE_BACKEND_URL = grailsApplication.config.layersService.internal.url
        LOGGER_SERVICE_BACKEND_URL = "${grailsApplication.config.loggerService.internal.url}/service"
    }

    Map cachedGroupedFacets = [:] // keep a copy in case method throws an exception and then blats the saved version

    def getFacetsCacheServiceBean() {
        facetsCacheServiceBean = applicationContext.getBean("facetsCacheService")
        return facetsCacheServiceBean
    }

    def JSONObject fullTextSearch(SpatialSearchRequestParams requestParams) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrences/search?${requestParams.getEncodedParams()}"
        getJsonElements(url)
    }

    def JSONObject cachedFullTextSearch(SpatialSearchRequestParams requestParams) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrences/search?${requestParams.getEncodedParams()}"
        getJsonElements(url)
    }

    def JSONObject getRecord(String id, Boolean hasClubView) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrence/${id.encodeAsURL()}"
        if (hasClubView) {
            url += "?apiKey=${grailsApplication.config.biocache.apiKey ?: ''}"
        }
        getJsonElements(url)
    }

    def JSONObject getCompareRecord(String id) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrence/compare?uuid=${id.encodeAsURL()}"
        getJsonElements(url)
    }

    def JSONArray getMapLegend(String queryString) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/mapping/legend?${queryString}"
        JSONArray json = getJsonElements(url)
        def facetName
        Map facetLabelsMap = [:]

        json.each { item ->
            if (!facetName) {
                // do this once
                facetName = item.fq?.tokenize(":")?.get(0)?.replaceFirst(/^\-/, "")
                try {
                    facetLabelsMap = facetsCacheServiceBean.getFacetNamesFor(facetName) // cached
                } catch (IllegalArgumentException iae) {
                    log.info "${iae.message}"
                }
            }

            if (facetLabelsMap && facetLabelsMap.containsKey(item.name)) {
                item.name = facetLabelsMap.get(item.name)
            }
        }
        json
    }

    def JSONArray getUserAssertions(String id) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrences/${id.encodeAsURL()}/assertions"
        getJsonElements(url)
    }

    def JSONArray getQueryAssertions(String id) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/occurrences/${id.encodeAsURL()}/assertionQueries"
        getJsonElements(url)
    }

    def JSONObject getDuplicateRecordDetails(JSONObject record) {
        if (record?.processed?.occurrence?.associatedOccurrences) {
            def status = record.processed.occurrence.duplicationStatus
            def uuid

            if (status == "R") {
                // reference record so use its UUID
                uuid = record.raw.uuid
            } else {
                // duplicate record so use the reference record UUID
                uuid = record.processed.occurrence.associatedOccurrences
            }

            def url = "${BIOCACHE_SERVICE_BACKEND_URL}/duplicates/${uuid.encodeAsURL()}"
            getJsonElements(url)
        }
    }

    @Cacheable("longTermCache")
    def JSONArray getDefaultFacets() {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/search/facets"
        getJsonElements(url)
    }

    @Cacheable("longTermCache")
    def JSONArray getErrorCodes() {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/assertions/user/codes"
        getJsonElements(url)
    }

    @Cacheable("longTermCache")
    def Map getGroupedFacets() {
        log.info "Getting grouped facets"
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/search/grouped/facets"

        if (grailsApplication.config.biocache.groupedFacetsUrl) {
            // some hubs use a custom JSON url
            url = "${grailsApplication.config.biocache.groupedFacetsUrl}"
        }

        Map groupedMap = [ "Custom" : []] // LinkedHashMap by default so ordering is maintained

        try {
            JSONArray groupedArray = getJsonElements(url)

            // simplify DS into a Map with key as group name and value as list of facets
            groupedArray.each { group ->
                groupedMap.put(group.title, group.facets.collect { it.field })
            }

            cachedGroupedFacets = deepCopy(groupedMap) // keep a deep copy

        } catch (Exception e) {
            log.warn "grouped facets failed to load: $e", e
            groupedMap = cachedGroupedFacets // fallback to saved copy
        }

        groupedMap
    }

    @CacheEvict(value="collectoryCache", allEntries=true)
    def doClearCollectoryCache() {
        "collectoryCache cache cleared\n"
    }

    @CacheEvict(value="longTermCache", allEntries=true)
    def doClearLongTermCache() {
        "longTermCache cache cleared\n"
    }

    /**
     * Perform POST for new assertion to biocache-service
     *
     * @param recordUuid
     * @param code
     * @param comment
     * @param userId
     * @param userDisplayName
     * @return Map postResponse
     */
    Map addAssertion(String recordUuid, String code, String comment, String userId, String userDisplayName,
                         String userAssertionStatus, String assertionUuid) {
        Map postBody =  [
                recordUuid: recordUuid,
                code: code,
                comment: comment,
                userAssertionStatus: userAssertionStatus,
                assertionUuid: assertionUuid,
                userId: userId,
                userDisplayName: userDisplayName,
                apiKey: grailsApplication.config.biocache.apiKey
        ]

        postFormData(BIOCACHE_SERVICE_BACKEND_URL + "/occurrences/assertions/add", postBody)
    }

    /**
     * Perform POST to delete an assertion on biocache-service
     *
     * @param recordUuid
     * @param assertionUuid
     * @return
     */
    def Map deleteAssertion(String recordUuid, String assertionUuid) {
        Map postBody =  [
                recordUuid: recordUuid,
                assertionUuid: assertionUuid,
                apiKey: grailsApplication.config.biocache.apiKey
        ]

        postFormData(BIOCACHE_SERVICE_BACKEND_URL + "/occurrences/assertions/delete", postBody)
    }

    @Cacheable("collectoryCache")
    def JSONObject getCollectionInfo(String id) {
        def url = "${COLLECTORY_BACKEND_URL}/lookup/summary/${id.encodeAsURL()}"
        getJsonElements(url)
    }

    @Cacheable("collectoryCache")
    def JSONArray getCollectionContact(String id){
        def url = "${COLLECTORY_BACKEND_URL}/ws/collection/${id.encodeAsURL()}/contact.json"
        getJsonElements(url)
    }

    @Cacheable("collectoryCache")
    def JSONArray getDataresourceContact(String id){
        def url = "${COLLECTORY_BACKEND_URL}/ws/dataResource/${id.encodeAsURL()}/contact.json"
        getJsonElements(url)
    }

    @Cacheable("longTermCache")
    def Map getLayersMetaData() {
        Map layersMetaMap = [:]
        def url = "${LAYERS_SERVICE_BACKEND_URL}/layers"

        try {
            def jsonArray = getJsonElements(url)
            jsonArray.each {
                Map subset = [:]
                subset << it // clone the original Map
                subset.layerID = it.uid
                subset.layerName = it.name
                subset.layerDisplayName = it.displayname
                subset.value = null
                subset.classification1 = it.classification1
                subset.units = it.environmentalvalueunits

                if (it.type == ENVIRONMENTAL) {
                    layersMetaMap.put("el" + it.id, subset)
                } else if (it.type == CONTEXTUAL) {
                    layersMetaMap.put("cl" + it.id, subset)
                }
            }
        } catch (RestClientException rce) {
            log.debug "Can't access layer service - ${rce.message}"
        }

        return layersMetaMap
    }

    /**
     * Query the BIE for GUIDs for a given list of names
     *
     * @param taxaQueries
     * @return
     */
    @Cacheable("longTermCache")
    def List<String> getGuidsForTaxa(List taxaQueries) {
        List guids = []

        if (taxaQueries.size() == 1) {
            String taxaQ = taxaQueries[0] ?: "*:*" // empty taxa search returns all records
            taxaQueries.addAll(taxaQ.split(" OR ") as List)
            taxaQueries.remove(0) // remove first entry
        }

        List encodedQueries = taxaQueries.collect { it.encodeAsURL() } // URL encode params

        // def url = BIE_SERVICE_BACKEND_URL + "/guid/batch?q=" + encodedQueries.join("&q=")
        def url = "${BIE_SERVICE_BACKEND_URL}/guid/batch?q=${encodedQueries.join("&q=")}"
        JSONObject guidsJson = getJsonElements(url)

        taxaQueries.each { key ->
            def match = guidsJson.get(key)[0]
            def guid = match?.acceptedIdentifier
            guids.add(guid)
        }

        return guids
    }

    /**
     * Get the CSV for ALA data quality checks meta data
     *
     * @return
     */
    @Cacheable("longTermCache")
    def String getDataQualityCsv() {
        String url = grailsApplication.config.dataQualityChecksUrl ?: "https://docs.google.com/spreadsheet/pub?key=0AjNtzhUIIHeNdHJOYk1SYWE4dU1BMWZmb2hiTjlYQlE&single=true&gid=0&output=csv"
        getText(url)
    }

    @Cacheable("longTermCache")
    def JSONArray getLoggerReasons() {
        def url = "${LOGGER_SERVICE_BACKEND_URL}/logger/reasons"
        def jsonObj = getJsonElements(url)
        jsonObj.findAll { !it.deprecated } // skip deprecated reason codes
    }

    @Cacheable("longTermCache")
    def JSONArray getLoggerSources() {
        def url = "${LOGGER_SERVICE_BACKEND_URL}/logger/sources"
        try {
            getJsonElements(url)
        } catch (Exception ex) {
            log.error "Error calling logger service: ${ex.message}", ex
        }
    }

    /**
     * Generate a Map of image url (key) with image file size (like ls -h) (value)
     *
     * @param images
     * @return
     */
    def Map getImageFileSizeInMb(JSONArray images) {
        Map imageSizes = [:]

        images.each { image ->
            String originalImageUrl = image.alternativeFormats?.imageUrl
            if (originalImageUrl) {
                Long imageSizeInBytes = getImageSizeInBytes(originalImageUrl)
                String formattedImageSize = FileUtils.byteCountToDisplaySize(imageSizeInBytes) // human readable value
                imageSizes.put(originalImageUrl, formattedImageSize)
            }
        }

        imageSizes
    }

    /**
     * Get list of dynamic facets for a given query (Sandbox)
     *
     * @param query
     * @return
     */
    List getDynamicFacets(String query) {
        def url = "${BIOCACHE_SERVICE_BACKEND_URL}/upload/dynamicFacets?q=${query}"
        JSONArray facets = getJsonElements(url)
        def dfs = []
        facets.each {
            if (it.name && it.displayName) {
                dfs.add([name: it.name, displayName: it.displayName])
            } // reduce to List of Maps
        }
        dfs
    }

    /**
     * Use HTTP HEAD to determine the file size of a URL (image)
     *
     * @param imageURL
     * @return
     * @throws Exception
     */
    private Long getImageSizeInBytes(String imageURL) throws Exception {
        // encode the path part of the URI - taken from http://stackoverflow.com/a/8962869/249327
        Long imageFileSize = 0l
        try {
            URL url = new URL(imageURL);
            URI uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
            HttpClient httpClient = new HttpClient()
            HeadMethod headMethod = new HeadMethod(uri.toString())
            httpClient.executeMethod(headMethod)
            String lengthString = headMethod.getResponseHeader("Content-Length")?.getValue() ?: "0"
            imageFileSize = Long.parseLong(lengthString)
        } catch (Exception ex) {
            log.error "Error getting image url file size: ${ex}", ex
        }

        return imageFileSize
    }

    /**
     * Perform HTTP GET on a JSON web service
     *
     * @param url
     * @return
     */
    def JSONElement getJsonElements(String url) {
        def conn = new URL(url).openConnection()
        try {
            conn.setConnectTimeout(10000)
            conn.setReadTimeout(50000)
            def json = conn.content.text
            return JSON.parse(json)
        } catch(FileNotFoundException e) {
            // most likely a server restart, so just log it and return empty results
            log.warn("Failed to get json from web service (${url}). ${e.getClass()} ${e.getMessage()}, ${e}")
            return JSON.parse("{}")
        } catch(Exception e) {
            log.warn("Failed to get json from web service (${url}). ${e.getClass()} ${e.getMessage()}, ${e}")
            return JSON.parse("{}")
        }
    }

    /**
     * Perform HTTP GET on a text-based web service
     *
     * @param url
     * @return
     */
    def String getText(String url) {
        def conn = new URL(url).openConnection()

        try {
            conn.setConnectTimeout(10000)
            conn.setReadTimeout(50000)
            def text = conn.content.text
            return text
        } catch (Exception e) {
            def error = "Failed to get text from web service (${url}). ${e.getClass()} ${e.getMessage()}, ${e}"
            log.error error
            //return null
            throw new RestClientException(error) // exception will result in no caching as opposed to returning null
        }
    }

    /**
     * Perform a POST with URL encoded params as POST body
     *
     * @param uri
     * @param postParams
     * @return postResponse (Map with keys: statusCode (int) and statusMsg (String)
     */
    def Map postFormData(String uri, Map postParams) {
        HTTPBuilder http = new HTTPBuilder(uri)
        Map postResponse = [:]

        http.request( Method.POST ) {

            send ContentType.URLENC, postParams

            response.success = { resp ->
                postResponse.statusCode = resp.statusLine.statusCode
                postResponse.statusMsg = resp.statusLine.reasonPhrase
                //assert resp.statusLine.statusCode == 201
            }

            response.failure = { resp ->
                //def error = [error: "Unexpected error: ${resp.statusLine.statusCode} : ${resp.statusLine.reasonPhrase}"]
                postResponse.statusCode = resp.statusLine.statusCode
                postResponse.statusMsg = resp.statusLine.reasonPhrase
                log.error "POST - Unexpected error: ${postResponse.statusCode} : ${postResponse.statusMsg}"
            }
        }

        postResponse
    }

    def JSONElement postJsonElements(String url, String jsonBody) {
        HttpURLConnection conn = null
        def charEncoding = "UTF-8"
        try {
            conn = new URL(url).openConnection()
            conn.setDoOutput(true)
            conn.setRequestProperty("Content-Type", "application/json;charset=${charEncoding}");
//            conn.setRequestProperty("Authorization", grailsApplication.config.api_key);
//            def user = userService.getUser()
//            if (user) {
//                conn.setRequestProperty(grailsApplication.config.app.http.header.userId, user.userId) // used by ecodata
//                conn.setRequestProperty("Cookie", "ALA-Auth="+java.net.URLEncoder.encode(user.userName, charEncoding)) // used by specieslist
//            }
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)
            wr.write(jsonBody)
            wr.flush()
            def resp = conn.inputStream.text
            if (!resp && conn.getResponseCode() == 201) {
                // Field guide code...
                resp = "{fileId: \"${conn.getHeaderField("fileId")}\" }"
            }
            wr.close()
            return JSON.parse(resp ?: "{}")
        } catch (SocketTimeoutException e) {
            def error = "Timed out calling web service. URL= ${url}."
            throw new RestClientException(error) // exception will result in no caching as opposed to returning null
        } catch (Exception e) {
            def error = "Failed calling web service. ${e.getMessage()} URL= ${url}." +
                        "statusCode: " +conn?.responseCode ?: "" +
                        "detail: " + conn?.errorStream?.text
            throw new RestClientException(error) // exception will result in no caching as opposed to returning null
        }
    }

    /**
     * Standard deep copy implementation
     *
     * Taken from http://stackoverflow.com/a/13155429/249327
     *
     * @param orig
     * @return
     */
    private def deepCopy(orig) {
        def bos = new ByteArrayOutputStream()
        def oos = new ObjectOutputStream(bos)
        oos.writeObject(orig); oos.flush()
        def bin = new ByteArrayInputStream(bos.toByteArray())
        def ois = new ObjectInputStream(bin)
        return ois.readObject()
    }
}
