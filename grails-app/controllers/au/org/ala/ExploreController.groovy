package au.org.ala

class ExploreController {
    def area() {
        def radius = params.radius ?: 5
        Map radiusToZoomLevelMap = grailsApplication.config.exploreYourArea.zoomLevels

        render("view": "/occurrence/exploreYourArea", model: [
            latitude: params.latitude ?: grailsApplication.config.default.location.latitude,
            longitude: params.longitude ?: grailsApplication.config.default.location.longitude,
            radius: radius,
            zoom: radiusToZoomLevelMap.get(radius),
            location: grailsApplication.config.default.location.address,
            speciesPageUrl: grailsApplication.config.bie.ui.url + "/species/"
        ])
    }
}
