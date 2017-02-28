package au.org.ala

class ExploreController {
    def area() {
        def radius = params.radius?:5
        Map radiusToZoomLevelMap = grailsApplication.config.exploreYourArea.zoomLevels

        render("view": "/occurrence/exploreYourArea", model: [
            latitude: params.latitude?:grailsApplication.config.exploreYourArea.lat,
            longitude: params.longitude?:grailsApplication.config.exploreYourArea.lng,
            radius: radius,
            zoom: radiusToZoomLevelMap.get(radius),
            location: grailsApplication.config.exploreYourArea.location,
            speciesPageUrl: grailsApplication.config.bie.baseUrl + "/species/"
        ])
    }
}
