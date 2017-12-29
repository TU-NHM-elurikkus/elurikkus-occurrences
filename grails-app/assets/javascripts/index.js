//= require jquery.cookie
//= require jquery.jsonp-2.4.0.min
//= require jquery.autocomplete
//= require leafletPlugins
//= require google-mutant
//= require purl
//= require map.common
//= require advancedSearch

var MAP_VAR; // Populated by index.gsp view

$(document).ready(function() {
    var mapInit = false;

    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        var id = $(this).attr('id');
        var tab = $(e.target).attr('href').replace('tab-', '');

        if(window.history) {
            window.history.replaceState({}, '', tab);
        } else {
            window.location.hash = tab;
        }

        if(id === 't5' && !mapInit) {
            initialiseMap();
            mapInit = true;
        }
    });

    // catch hash URIs and trigger tabs
    if(location.hash !== '') {
        $('.nav-tabs a[href="#tab-' + location.hash.substr(1) + '"]').tab('show');
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

        try {
            drawWktObj(wktString);
            $('#wktInput').val('');
            $('#wkt-input-error').hide();
        } catch(err) {
            $('#wkt-input-error').show();
        }
    });
});

// TODO: DRY with occurrenceMap:OccurrenceMap.initialize
function initialiseMap() {
    if(MAP_VAR.map !== null) {
        return;
    }

    // initialise map
    MAP_VAR.map = L.map('leafletMap', {
        center: [MAP_VAR.defaultLatitude, MAP_VAR.defaultLongitude],
        zoomControl: false,
        zoom: MAP_VAR.defaultZoom,
        minZoom: 1,
        scrollWheelZoom: false
    });

    L.control.zoom({
        position: 'topleft',
        zoomInTitle: $.i18n.prop('advancedsearch.js.map.zoomin'),
        zoomOutTitle: $.i18n.prop('advancedsearch.js.map.zoomout')
    }).addTo(MAP_VAR.map);

    drawI18N();

    // add edit drawing toolbar
    // Initialise the FeatureGroup to store editable layers
    MAP_VAR.drawnItems = new L.FeatureGroup();
    MAP_VAR.map.addLayer(MAP_VAR.drawnItems);

    // Initialise the draw control and pass it the FeatureGroup of editable layers
    var drawControls = new L.Control.Draw({
        edit: {
            featureGroup: MAP_VAR.drawnItems
        },
        draw: {
            circlemarker: false,
            marker: false,
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

    MAP_VAR.map.addControl(drawControls);

    MAP_VAR.map.on('draw:created', function(e) {
        // setup onclick event for this object
        var layer = e.layer;
        var center = typeof layer.getLatLng === 'function' ? layer.getLatLng() : layer.getBounds().getCenter();

        generatePopup(layer, center, MAP_VAR.query, MAP_VAR.map);

        MAP_VAR.drawnItems.addLayer(layer);
    });

    MAP_VAR.map.on('draw:edited', function(e) {
        // setup onclick event for this object
        var layers = e.layers;

        layers.eachLayer(function(layer) {
            generatePopup(layer, layer._latlng, MAP_VAR.query, MAP_VAR.map);
        });
    });

    // add the default base layer
    MAP_VAR.map.addLayer(defaultBaseLayer);

    // Google map layers
    var roadLayer = L.gridLayer.googleMutant({ type: 'roadmap' });
    var terrainLayer = L.gridLayer.googleMutant({ type: 'terrain' });
    var hybridLayer = L.gridLayer.googleMutant({ type: 'satellite' });

    L.control.coordinates({ position: 'bottomright', useLatLngOrder: true }).addTo(MAP_VAR.map); // coordinate plugin

    var baseLayers = {};
    baseLayers[$.i18n.prop('advancedsearch.js.map.draw.layers.Minimal')] = defaultBaseLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.draw.layers.Road')] = roadLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.draw.layers.Terrain')] = terrainLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.draw.layers.Satellite')] = hybridLayer;

    MAP_VAR.layerControl = L.control.layers(baseLayers, {}, { collapsed: true, position: 'topleft' });

    MAP_VAR.layerControl.addTo(MAP_VAR.map);

    L.Util.requestAnimFrame(MAP_VAR.map.invalidateSize, MAP_VAR.map, !1, MAP_VAR.map._container);
}
