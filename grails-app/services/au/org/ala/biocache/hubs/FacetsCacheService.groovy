package au.org.ala.biocache.hubs

import org.apache.commons.lang.StringUtils
import org.codehaus.groovy.grails.web.json.JSONObject

import javax.annotation.PostConstruct

/**
 * Service to cache the facet values available from a given data hub.
 * Used to populate the values in select drop-down lists in advanced search page.
 */
class FacetsCacheService {
    def webServicesService
    def grailsApplication

    Map facetsMap = [:]  // generated via SOLR lookup
    List facetsList = [] // set via config file below

    /**
     * Init method - load facetsList from config file
     *
     * @return
     */
    @PostConstruct
    def init() {
        facetsList = grailsApplication.config.facets?.cached?.split(',') ?: []
    }

    /**
     * Get the facets values (and labels if available) for the requested facet field.
     *
     * @param facet
     * @return
     */
    def Map getFacetNamesFor(String facet) {
        if (!facetsMap) {
            loadSearchResults()
        }
        return facetsMap?.get(facet)
    }

    /**
     * Can be triggered from the admin page. Note: the longTermCache needs to be
     * cleared as well (admin function does this).
     */
    def void clearCache() {
        facetsMap = [:]
        init() //  reload config values
    }

    /**
     * Do a search for all records and store facet values for the requested facet fields
     */
    private void loadSearchResults() {
        SpatialSearchRequestParams requestParams = new SpatialSearchRequestParams()
        requestParams.setQ("*:*")
        requestParams.setPageSize(0)
        requestParams.setFlimit(-1)
        requestParams.setFacets(facetsList as String[])
        JSONObject sr = webServicesService.cachedFullTextSearch(requestParams)

        sr.facetResults.each { fq ->
            def fieldName = fq.fieldName
            def fields = [:]
            fq.fieldResult.each {
                if (it.fq) {
                    def values = it.fq.tokenize(":")
                    def value = StringUtils.remove(values[1], '"') // some values have surrounding quotes
                    def label = it.label
                    if(value == '*') {
                        label = 'advancedsearch.matchAnything'
                    } else if (!label) {
                        label = "${fieldName}.${value}".replace(" ", "").replace("\'", "").replace(".'", "")
                    }
                    fields.put(value, label)
                } else {
                    fields.put(it.label, it.label)
                }
            }

            if (fields.size() > 0) {
                facetsMap.put(fieldName, fields)
            } else {
                log.warn "No facet values found for ${fieldName}"
            }
        }
    }

}
