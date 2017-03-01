modules = {
    elurikkusStyle {
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

    overrides {
        bootstrap2 {
            dependsOn 'bootstrap4'
        }
    }
}
