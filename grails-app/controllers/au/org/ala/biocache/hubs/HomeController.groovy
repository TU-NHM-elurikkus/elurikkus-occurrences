package au.org.ala.biocache.hubs

class HomeController {

    def facetsCacheService

    def index() throws Exception {
        addCommonModel()
    }

    def advancedSearch(AdvancedSearchParams requestParams) {
        log.debug "Home controller advancedSearch page"
        //flash.message = "Advanced search for: ${requestParams.toString()}"
        redirect(controller: "occurrences", action:"search", params: requestParams.toParamMap())
    }

    private Map addCommonModel() {
        def model = [:]

        facetsCacheService.facetsList.each { fn ->
            model.put(fn, facetsCacheService.getFacetNamesFor(fn))
        }

        model
    }
}
