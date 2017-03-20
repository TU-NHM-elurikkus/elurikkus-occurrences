modules = {
    elurikkusCoreHub {
        dependsOn 'jquery_i18n'
        defaultBundle 'main-core'
        resource url: [dir: 'css', file: 'autocomplete.css', plugin: 'biocache-hubs']
        // resource url: [dir: 'css', file: 'base.css', plugin: 'biocache-hubs'], attrs: [ media: 'all' ]
        resource url: [dir: 'js', file: 'jquery.autocomplete.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'js', file: 'biocache-hubs.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'html5.js', plugin: 'biocache-hubs'], wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }, disposition: 'head'
    }

    elurikkusSearch {
        // Modified search plugin JS.
        resource url: [dir: 'js', file: 'search.js']
        // Maybe keep it, maybe ditch it.
        resource url: [dir: 'css', file: 'print-search.css', plugin: 'biocache-hubs'], attrs: [ media: 'print' ]
        /**
         * New CSS with overrides. Should replace overrides with legimate CSS
         * and the file should replace search.css completely.
         */
        resource url: [dir: 'css', file: 'elurikkus-search.css']
        // Carried over from search-core module.
        resource url: [dir: 'js', file: 'jquery.cookie.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'jquery.inview.min.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'jquery.jsonp-2.4.0.min.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'charts2.js', plugin: 'biocache-hubs'], disposition: 'head'
    }

    recordView {
        dependsOn 'jquery, fontawesome, jquery_i18n'
        resource url: [dir: 'css', file: 'record-view.css']
        resource url: [dir: 'css', file: 'print-record.css', plugin: 'biocache-hubs'], attrs: [ media: 'print' ]
        resource url: [dir: 'js', file: 'audiojs/audio.min.js', plugin: 'biocache-hubs'], disposition: 'head', exclude: '*'
        resource url: [dir: 'js', file: 'jquery.i18n.properties-1.0.9.js', plugin: 'biocache-hubs']
        resource url: [dir: 'js', file: 'record-view.js']
        resource url: [dir: 'js', file: 'charts2.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'js', file: 'wms2.js', plugin: 'biocache-hubs'], disposition: 'head'
    }

    occurrenceMap {
        dependsOn 'jquery'
        resource url: [dir: 'js', file: 'occurrenceMap.js']
    }

    exploreArea {
        dependsOn 'jquery'
        resource url: [dir: 'js', file: 'exploreArea.js'], disposition: 'head'
        resource url: [dir: 'js', file: 'magellan.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'css', file: 'exploreYourArea.css', plugin: 'biocache-hubs'], attrs: [media: 'all']
        resource url: [dir: 'js', file: 'purl.js', plugin: 'biocache-hubs'], disposition: 'head'
    }

    // Tooltips required by Bootstrap 4.
    tether {
        resource url: [dir: 'js', file: 'tether.min.js', plugin: 'elurikkus-commons']
        resource url: [dir: 'css', file: 'tether.min.css', plugin: 'elurikkus-commons']
    }

    // TODO: Try and sort out the mess with all the bootstrap versions.
    bootstrap4 {
        dependsOn: tether
        resource url: [dir: 'js', file: 'bootstrap.min.js', plugin: 'elurikkus-commons' , disposition: 'head']
        resource url: [dir: 'css', file: 'bootstrap.min.css', plugin: 'elurikkus-commons' , attrs: [media: 'screen, projection, print']]
        resource url: [dir: 'css', file: 'bootstrap-grid.min.css', plugin: 'elurikkus-commons', attrs: [media: 'screen, projection, print']]
    }

    bootstrap {
        dependsOn 'bootstrap2'
    }

    overrides {
        bootstrap2 {
            dependsOn 'bootstrap4'
        }
    }
}
