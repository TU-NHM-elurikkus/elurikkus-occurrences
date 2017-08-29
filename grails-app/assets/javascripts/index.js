//= require jquery
//= require jquery.cookie
//= require jquery.inview.min
//= require jquery.jsonp-2.4.0.min
//= require jquery_migration
//= require jquery.autocomplete
//= require charts2
//= require ekko-lightbox-5.2.0
//= require leafletPlugins
//= require amplify
//= require purl
//= require nanoscroller
//= require common
//= require ala-charts
//= require bootstrap-combobox
//= require bootstrap-slider
//= require map.common
//= require advancedSearch

$.i18n.properties({
    name: 'messages',
    path: BC_CONF.contextPath + '/messages/i18n/',
    mode: 'map',
    language: BC_CONF.locale
});

$(document).ready(function() {
    var mapInit = false;

    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {

        var id = $(this).attr('id');

        location.hash = 'tab-' + $(e.target).attr('href').substr(1);

        if(id === 't5' && !mapInit) {
            initialiseMap();
            mapInit = true;
        }
    });

    // catch hash URIs and trigger tabs
    if(location.hash !== '') {
        $('.nav-tabs a[href="' + location.hash.replace('tab-', '') + '"]').tab('show');
    } else {
        $('.nav-tabs a:first').tab('show');
    }

    // Toggle show/hide sections with plus/minus icon
    $('.toggleTitle').not('#extendedOptionsLink').click(function(e) {
        e.preventDefault();
        var $this = this;
        $(this).next('.toggleSection').slideToggle('slow', function() {
            // change plus/minus icon when transition is complete
            $($this).toggleClass('toggleTitleActive');
        });
    });

    $('.toggleOptions').click(function(e) {
        e.preventDefault();
        var $this = this;
        var targetEl = $(this).attr('id');
        $(targetEl).slideToggle('slow', function() {
            // change plus/minus icon when transition is complete
            $($this).toggleClass('toggleOptionsActive');
        });
    });

    // Add WKT string to map button click
    $('#addWkt').click(function() {
        var wktString = $('#wktInput').val();

        if(wktString) {
            drawWktObj($('#wktInput').val());
        } else {
            alert('Please paste a valid WKT string'); // TODO i18n this
        }
    });

    $('#catalogueSearchQueries').on('input', function() {
        var value = $('#catalogueSearchQueries').val();

        $('#catalogueSearchButton').attr('disabled', value.trim().length === 0);
    });
});

function initialiseMap() {
    if(MAP_VAR.map !== null) {
        return;
    }

    // initialise map
    MAP_VAR.map = L.map('leafletMap', {
        center: [MAP_VAR.defaultLatitude, MAP_VAR.defaultLongitude],
        zoom: MAP_VAR.defaultZoom,
        minZoom: 1,
        scrollWheelZoom: false
    });

    // add edit drawing toolbar
    // Initialise the FeatureGroup to store editable layers
    MAP_VAR.drawnItems = new L.FeatureGroup();
    MAP_VAR.map.addLayer(MAP_VAR.drawnItems);

    // Initialise the draw control and pass it the FeatureGroup of editable layers
    MAP_VAR.drawControl = new L.Control.Draw({
        edit: {
            featureGroup: MAP_VAR.drawnItems
        },
        draw: {
            polyline: false,
            rectangle: {
                shapeOptions: {
                    color: '#bada55'
                }
            },
            circle: {
                shapeOptions: {
                    color: '#bada55'
                }
            },
            marker: false,
            polygon: {
                allowIntersection: false, // Restricts shapes to simple polygons
                drawError: {
                    color: '#e1e100', // Color the shape will turn when intersects
                    message: '<strong>Oh snap!<strong> you can\'t draw that!' // Message that will show when intersect
                },
                shapeOptions: {
                    color: '#bada55'
                }
            }
        }
    });
    MAP_VAR.map.addControl(MAP_VAR.drawControl);

    MAP_VAR.map.on('draw:created', function(e) {
        // setup onclick event for this object
        var layer = e.layer;
        var center = layer.getBounds().getCenter();

        generatePopup(layer, center, MAP_VAR.query, MAP_VAR.map);
        addClickEventForVector(layer, MAP_VAR.query, MAP_VAR.map);

        MAP_VAR.drawnItems.addLayer(layer);
    });

    MAP_VAR.map.on('draw:edited', function(e) {
        // setup onclick event for this object
        var layers = e.layers;

        layers.eachLayer(function(layer) {
            generatePopup(layer, layer._latlng, MAP_VAR.query, MAP_VAR.map);
            addClickEventForVector(layer, MAP_VAR.query, MAP_VAR.map);
        });
    });

    // add the default base layer
    MAP_VAR.map.addLayer(defaultBaseLayer);

    L.control.coordinates({ position: 'bottomright', useLatLngOrder: true }).addTo(MAP_VAR.map); // coordinate plugin

    MAP_VAR.layerControl = L.control.layers(MAP_VAR.baseLayers, MAP_VAR.overlays, { collapsed: true, position: 'topleft' });
    MAP_VAR.layerControl.addTo(MAP_VAR.map);

    L.Util.requestAnimFrame(MAP_VAR.map.invalidateSize, MAP_VAR.map, !1, MAP_VAR.map._container);
    L.Browser.any3d = false; // FF bug prevents selects working properly
}
