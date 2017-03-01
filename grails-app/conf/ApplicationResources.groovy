modules = {
//    application {
//        resource url:'js/application.js'
//    }

    // Define your skin module here - it must 'dependsOn' either bootstrap (ALA version) or bootstrap2 (unmodified) and core

    generic {
        dependsOn 'bootstrap2', 'hubCore' //
        resource url: [dir:'css', file:'generic.css']
    }

    bootstrap {
        dependsOn 'jquery'
        resource url: [dir:'bootstrap/css', file:'bootstrap.min.css', plugin: 'biocache-hubs'],attrs: [ media: 'all' ]
        resource url: [dir:'bootstrap/css', file:'bootstrap-responsive.min.css', plugin: 'biocache-hubs'],attrs: [ media: 'all' ]
        resource url: [dir:'bootstrap/js', file:'bootstrap.js', plugin:'biocache-hubs'], disposition: 'head'

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
}
