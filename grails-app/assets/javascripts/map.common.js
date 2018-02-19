//= require es6-promise
//= require google-mutant
//= require tile.stamen-v1.3.0

var BC_CONF; // Populated by elurikkus.gsp inline script
var MAP_VAR; // Populated by index.gsp view

/*  Common map (Leaflet) functions */
function addClickEventForVector(layer, query, map) {
    layer.on('click', function(e) {
        generatePopup(layer, e.latlng, query, map);
    });
}

function generatePopup(layer, latlng, query, map) {
    var params = '';

    if($.isFunction(layer.getRadius)) {
        // circle
        params = getParamsForCircle(layer, query);
    } else {
        var wkt = new Wkt.Wkt();
        var geojson = layer.toGeoJSON();
        var geostr = JSON.stringify(geojson);
        wkt.read(geostr);
        params = getParamsforWKT(wkt.write(), query);
    }

    if(!latlng) {
        if($.isFunction(layer.getBounds)) {
            latlng = layer.getBounds().getCenter();
        } else {
            latlng = layer.getLatLng();
        }
    }

    var recordsLink = BC_CONF.contextPath + '/occurrences/search' + params + '#map';

    var coordsStr = latlng.lat + '-' + latlng.lng;
    var speciesID = 'speciesCount-' + coordsStr;
    var occurrenceID = 'occurrenceCount-' + coordsStr;

    L.popup()
        .setLatLng(latlng)
        .setContent(
            $.i18n.prop('advancedsearch.js.map.popup.speciescount') + ': <b id="' + speciesID + '">calculating...</b>' +
            '<br />' +
            $.i18n.prop('advancedsearch.js.map.popup.occurrencecount') + ': <b id="' + occurrenceID + '">calculating...</b>' +
            '<br />' +
            '<a id="showOnlyTheseRecords" href="' + recordsLink + '">' +
                '<span class="fa fa-search"></span> ' +
                $.i18n.prop('advancedsearch.js.map.popup.linkText') +
            '</a>'
        )
        .openOn(map);

    getSpeciesCountInArea(params, speciesID);
    getOccurrenceCountInArea(params, occurrenceID);
}

function getSpeciesCountInArea(params, speciesID) {
    $.getJSON(BC_CONF.biocacheServiceUrl + '/occurrence/facets.json' + params + '&facets=taxon_name&callback=?',
        function(data) {
            document.getElementById(speciesID).innerHTML = data.length ? data[0].count : 0;
        });
}

function getOccurrenceCountInArea(params, occurrenceID) {
    $.getJSON(BC_CONF.biocacheServiceUrl + '/occurrences/search.json' + params + '&pageSize=0&facet=off&callback=?',
        function(data) {
            var occurrenceCount = data.totalRecords;

            document.getElementById(occurrenceID).innerHTML = occurrenceCount;
        });
}

function getParamsforWKT(wkt, query) {
    return '?' + getExistingParams(query) + '&wkt=' + encodeURI(wkt.replace(' ', '+'));
}

function getParamsForCircle(circle, query) {
    var latlng = circle.getLatLng();
    var radius = Math.round((circle.getRadius() / 1000) * 10) / 10; // convert to km (from m) and round to 1 decmial place
    return '?' + getExistingParams(query) + '&radius=' + radius + '&lat=' + latlng.lat + '&lon=' + latlng.lng;
}

function getExistingParams(query) {
    var paramsObj = $.url(query).param();
    if(!paramsObj.q) {
        paramsObj.q = '*:*';
    }
    delete paramsObj.wkt;
    delete paramsObj.lat;
    delete paramsObj.lon;
    delete paramsObj.radius;
    paramsObj.qc = BC_CONF.queryContext;
    return $.param(paramsObj);
}

function drawWktObj(wktString) {
    var wkt = new Wkt.Wkt();
    wkt.read(wktString);
    var wktObject = wkt.toObject({ color: '#bada55' });
    generatePopup(wktObject, null, MAP_VAR.query, MAP_VAR.map);
    addClickEventForVector(wktObject, MAP_VAR.query, MAP_VAR.map);
    MAP_VAR.drawnItems.addLayer(wktObject);

    if(wktObject.getBounds !== undefined && typeof wktObject.getBounds === 'function') {
        // For objects that have defined bounds or a way to get them
        MAP_VAR.map.fitBounds(wktObject.getBounds());
    } else {
        if(focus && wktObject.getLatLng !== undefined && typeof wktObject.getLatLng === 'function') {
            MAP_VAR.map.panTo(wktObject.getLatLng());
        }
    }
}

/**
 Translations for leaflet-draw library
 */
function drawI18N() {
    L.drawLocal.draw.toolbar.actions.title = $.i18n.prop('leaflet.draw.actions.title');
    L.drawLocal.draw.toolbar.actions.text = $.i18n.prop('leaflet.draw.actions.text');
    L.drawLocal.draw.toolbar.finish.title = $.i18n.prop('leaflet.draw.finish.title');
    L.drawLocal.draw.toolbar.finish.text = $.i18n.prop('leaflet.draw.finish.text');
    L.drawLocal.draw.toolbar.undo.title = $.i18n.prop('leaflet.draw.undo.title');
    L.drawLocal.draw.toolbar.undo.text = $.i18n.prop('leaflet.draw.undo.text');
    L.drawLocal.draw.toolbar.buttons.polygon = $.i18n.prop('leaflet.draw.buttons.polygon');
    L.drawLocal.draw.toolbar.buttons.rectangle = $.i18n.prop('leaflet.draw.buttons.rectangle');
    L.drawLocal.draw.toolbar.buttons.circle = $.i18n.prop('leaflet.draw.buttons.circle');
    L.drawLocal.draw.handlers.polygon.tooltip.start = $.i18n.prop('leaflet.draw.polygon.tooltip.start');
    L.drawLocal.draw.handlers.polygon.tooltip.cont = $.i18n.prop('leaflet.draw.polygon.tooltip.cont');
    L.drawLocal.draw.handlers.polygon.tooltip.end = $.i18n.prop('leaflet.draw.polygon.tooltip.end');
    L.drawLocal.draw.handlers.rectangle.tooltip.start = $.i18n.prop('leaflet.draw.rectangle.tooltip.start');
    L.drawLocal.draw.handlers.simpleshape.tooltip.end = $.i18n.prop('leaflet.draw.simpleshape.tooltip.end');
    L.drawLocal.draw.handlers.circle.tooltip.start = $.i18n.prop('leaflet.draw.circle.tooltip.start');
    L.drawLocal.draw.handlers.circle.radius = $.i18n.prop('leaflet.draw.circle.radius');
    L.drawLocal.edit.toolbar.buttons.edit = $.i18n.prop('leaflet.draw.edit.toolbar.buttons.edit');
    L.drawLocal.edit.toolbar.actions.save.text = $.i18n.prop('leaflet.draw.edit.toolbar.actions.save.text');
    L.drawLocal.edit.toolbar.actions.save.title = $.i18n.prop('leaflet.draw.edit.toolbar.actions.save.title');
    L.drawLocal.edit.toolbar.actions.cancel.title = $.i18n.prop('leaflet.draw.edit.toolbar.actions.cancel.title');
    L.drawLocal.edit.toolbar.actions.cancel.text = $.i18n.prop('leaflet.draw.edit.toolbar.actions.cancel.text');
    L.drawLocal.edit.handlers.edit.tooltip.text = $.i18n.prop('leaflet.draw.edit.handlers.edit.tooltip.text');
    L.drawLocal.edit.handlers.edit.tooltip.subtext = $.i18n.prop('leaflet.draw.edit.handlers.edit.tooltip.subtext');
    L.drawLocal.edit.toolbar.buttons.remove.remove = $.i18n.prop('leaflet.draw.edit.toolbar.buttons.remove.remove');
    L.drawLocal.edit.toolbar.actions.clearAll.text = $.i18n.prop('leaflet.draw.edit.toolbar.actions.clearAll.text');
    L.drawLocal.edit.toolbar.actions.clearAll.title = $.i18n.prop('leaflet.draw.edit.toolbar.actions.clearAll.title');
    L.drawLocal.edit.handlers.remove.tooltip.text = $.i18n.prop('leaflet.draw.edit.handlers.remove.tooltip.text');
}

function getBaseLayers() {
    // Google map layers
    var minimalBaseLayer = L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, imagery &copy; <a href="https://carto.com/attribution">CartoDB</a>',
        subdomains: 'abcd',
        mapid: '',
        token: ''
    });
    var roadLayer = L.gridLayer.googleMutant({ type: 'roadmap' });
    var terrainLayer = L.gridLayer.googleMutant({ type: 'terrain' });
    var hybridLayer = L.gridLayer.googleMutant({ type: 'satellite' });
    var blackWhiteLayer = new L.StamenTileLayer('toner');

    var baseLayers = {};
    baseLayers[$.i18n.prop('advancedsearch.js.map.layers.Minimal')] = minimalBaseLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.layers.Road')] = roadLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.layers.Terrain')] = terrainLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.layers.Satellite')] = hybridLayer;
    baseLayers[$.i18n.prop('advancedsearch.js.map.layers.BlackWhite')] = blackWhiteLayer;

    return baseLayers;
}

function getStoredMapLayer() {
    var storedLayerName;
    try {
        storedLayerName = localStorage.getItem('defaultMapLayer');
    } catch(e) {
        // localStorage not available
        storedLayerName = $.i18n.prop('advancedsearch.js.map.layers.Minimal');
    }
    return storedLayerName;
}

function setStoredMapLayer(layerName) {
    try {
        localStorage.setItem('defaultMapLayer', layerName);
    } catch(e) {
        // localStorage not available
    }
}

function onBaseLayerChange(e) {
    setStoredMapLayer(e.name)
}
