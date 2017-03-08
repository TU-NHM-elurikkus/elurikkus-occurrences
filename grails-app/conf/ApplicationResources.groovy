modules = {
    elurikkusStyle {
        resource url: [dir: 'css', file: 'elurikkus-cms.css']
        resource url: [dir: 'css', file: 'elurikkus.css']
    }

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
        resource url: [dir:'js', file: 'search.js']
        // Maybe keep it, maybe ditch it.
        resource url:[dir:'css', file:'print-search.css', plugin:'biocache-hubs'], attrs: [ media: 'print' ]
        // Temporary, should remove it eventually.
        resource url:[dir:'css', file:'search.css', plugin:'biocache-hubs'], attrs: [ media: 'all' ]
        /**
         * New CSS with overrides. Should replace overrides with legimate CSS
         * and the file should replace search.css completely.
         */
        resource url: [dir: 'css', file: 'elurikkus-search.css']
        // Carried over from search-core module.
        resource url:[dir:'js', file:'jquery.cookie.js', plugin:'biocache-hubs']
        resource url:[dir:'js', file:'jquery.inview.min.js', plugin:'biocache-hubs']
        resource url:[dir:'js', file:'jquery.jsonp-2.4.0.min.js', plugin:'biocache-hubs']
        resource url:[dir:'js', file:'charts2.js', plugin:'biocache-hubs'], disposition: 'head'
    }

    // Tooltips required by Bootstrap 4.
    tether {
        resource url: [dir: 'js', file: 'tether.min.js']
        resource url: [dir: 'css', file: 'tether.min.css']
    }

    bootstrap4 {
        dependsOn 'tether'
        resource url: [dir: 'js', file: 'bootstrap.min.js', disposition: 'head']
        resource url: [dir: 'css', file: 'bootstrap.min.css', attrs: [media: 'screen, projection, print']]
        resource url: [dir: 'css', file: 'bootstrap-grid.min.css', attrs: [media: 'screen, projection, print']]
    }

    occurrenceMap {
        dependsOn 'jquery'
        resource url: [dir:'js', file:'occurrenceMap.js']
    }

    exploreArea {
        dependsOn 'jquery'
        resource url: [dir: 'js', file: 'exploreArea.js'], disposition: 'head'
        resource url: [dir: 'js', file: 'magellan.js', plugin: 'biocache-hubs'], disposition: 'head'
        resource url: [dir: 'css', file: 'exploreYourArea.css', plugin: 'biocache-hubs'], attrs: [media: 'all']
        resource url: [dir: 'js', file: 'purl.js', plugin: 'biocache-hubs'], disposition: 'head'
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
