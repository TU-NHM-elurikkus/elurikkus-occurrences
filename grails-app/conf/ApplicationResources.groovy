modules = {
    elurikkusCoreHub {
        dependsOn 'bootstrap, jquery_i18n'
        defaultBundle 'main-core'

        /**
         * New CSS with overrides. Should replace overrides with legimate CSS
         * and the file should replace search.css completely.
         */
        resource url: [dir: 'css', file: 'elurikkus-search.css']
        resource url: [dir: 'css', file: 'autocomplete.css', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'jquery.autocomplete.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'js', file: 'biocache-hubs.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'html5.js', plugin: 'biocache-hubs'], wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }, disposition: 'head'
    }

    elurikkusSearch {
        // Modified search plugin JS.
        resource url: [dir: 'js', file: 'search.js']
        // Maybe keep it, maybe ditch it.
        resource url: [dir: 'css', file: 'print-search.css', plugin: 'biocache-hubs'], attrs: [ media: 'print' ]
        // Carried over from search-core module.
        resource url: [dir: 'js', file: 'jquery.cookie.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'jquery.inview.min.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'jquery.jsonp-2.4.0.min.js', plugin: 'biocache-hubs']
    }

    recordView {
        dependsOn 'jquery, fontawesome, jquery_i18n'

        resource url: [dir: 'css', file: 'record-view.css']
        resource url: [dir: 'css', file: 'print-record.css', plugin: 'biocache-hubs'], attrs: [ media: 'print' ]
        resource url: [dir: 'js', file: 'jquery.i18n.properties-1.0.9.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'record-view.js']
        resource url: [dir: 'js', file: 'charts2.js'], disposition: 'head'
        resource url: [dir: 'js', file: 'wms2.js', plugin: 'biocache-hubs'], disposition: 'head'
    }

    occurrenceMap {
        dependsOn 'jquery'

        resource url: [dir: 'js', file: 'occurrenceMap.js']
    }

    mapCommonOverride {
        dependsOn 'jquery', 'purl'

        resource url:[dir:'js', file:'map.common.js']
    }

    exploreArea {
        dependsOn 'jquery, fontawesome'

        resource url: [dir: 'js', file: 'exploreArea.js'], disposition: 'head'
        resource url: [dir: 'js', file: 'magellan.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'css', file: 'exploreYourArea.css'], attrs: [media: 'all']
        resource url: [dir: 'js', file: 'purl.js', plugin: 'biocache-hubs'], disposition: 'head'
    }

    lightbox {
        defaultBundle 'main-core'

        resource url: [dir: 'js', file: 'ekko-lightbox.min.js'], disposition: 'head'
        resource url: [dir: 'css', file: 'ekko-lightbox.min.css'], disposition: 'head'
    }

    leafletOverride {
        //defaultBundle 'leaflet'
        dependsOn 'jquery_i18n'

        resource url:[dir:'js/leaflet-0.7.2', file:'leaflet.css', plugin:'biocache-hubs'], attrs: [ media: 'all' ]
        resource url:[dir:'js/leaflet-0.7.2', file:'leaflet.js', plugin:'biocache-hubs']

    }

    leafletPluginsOverride {
        dependsOn 'leafletOverride'
        defaultBundle 'leafletPlugins'

        resource url: [plugin: "biocache-hubs", dir: 'js/leaflet-plugins/fullscreen', file: 'Control.FullScreen.css']
        resource url: [plugin: "biocache-hubs", dir: 'js/leaflet-plugins/fullscreen', file: 'Control.FullScreen.js']
        resource url:[dir:'js/leaflet-plugins/layer/tile', file:'Google.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/coordinates', file:'Leaflet.Coordinates-0.1.4.css', plugin:'biocache-hubs'], attrs: [ media: 'all' ]
        resource url:[dir:'js/leaflet-plugins/coordinates', file:'Leaflet.Coordinates-0.1.4.ie.css', plugin:'biocache-hubs'], attrs: [ media: 'all' ], wrapper: { s -> "<!--[if lt IE 8]>$s<![endif]-->" }
        resource url:[dir:'js/leaflet-plugins/layer/tile', file:'Google.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/spin', file:'spin.min.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/spin', file:'leaflet.spin.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/coordinates', file:'Leaflet.Coordinates-0.1.4.min.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/draw', file:'leaflet.draw.css', plugin:'biocache-hubs'], attrs: [ media: 'all' ]
        resource url:[dir:'js/leaflet-plugins/draw', file:'leaflet.draw-src.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/wicket', file:'wicket.js', plugin:'biocache-hubs']
        resource url:[dir:'js/leaflet-plugins/wicket', file:'wicket-leaflet.js', plugin:'biocache-hubs']
        resource url:[dir:'js', file:'LeafletToWKT.js', plugin:'biocache-hubs']
    }


    // Override biocache-hubs plugin style.
    searchMapOverride {
        resource url: [dir:'css', file:'searchMap.css'], attrs: [media: 'all']
    }

    chartsOverride {
        dependsOn 'bootstrapToggle', 'bootstrapMultiselect'

        resource url: [dir: 'css', file: 'ALAChart.css'], attrs: [media: 'all']
        resource url: [dir: 'js', file: 'ALAChart.js']
        resource url: [dir: 'js', file: 'charts2.js'], disposition: 'head'
        resource url: [dir: 'js', file: 'Chart.min.js', plugin: 'ala-charts-plugin']
        resource url: [dir: 'js', file: 'slider.js', plugin: 'ala-charts-plugin']
        resource url: [dir: 'js', file: 'moment.min.js', plugin: 'ala-charts-plugin']
    }
}
