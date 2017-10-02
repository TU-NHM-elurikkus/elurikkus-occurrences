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
        wkt.fromObject(layer);
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

    L.popup()
        .setLatLng([latlng.lat, latlng.lng])
        .setContent(
            'species count: <b id="speciesCountDiv">calculating...</b>' +
            '<br />' +
            'occurrence count: <b id="occurrenceCountDiv">calculating...</b>' +
            '<br />' +
            '<a id="showOnlyTheseRecords" href="' + recordsLink + '">' +
                '<span class="fa fa-search"></span>' +
                $.i18n.prop('search.map.popup.linkText') +
            '</a>'
        )
        .openOn(map);

    getSpeciesCountInArea(params);
    getOccurrenceCountInArea(params);
}

function getSpeciesCountInArea(params) {
    $.getJSON(BC_CONF.biocacheServiceUrl + '/occurrence/facets.json' + params + '&facets=taxon_name&callback=?',
        function(data) {
            document.getElementById('speciesCountDiv').innerHTML = data.length ? data[0].count : 0;
        });
}

function getOccurrenceCountInArea(params) {
    $.getJSON(BC_CONF.biocacheServiceUrl + '/occurrences/search.json' + params + '&pageSize=0&facet=off&callback=?',
        function(data) {
            var occurrenceCount = data.totalRecords;

            document.getElementById('occurrenceCountDiv').innerHTML = occurrenceCount;
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

function addZoomControl(map) {
    L.control.zoom({
        zoomInTitle: $.i18n.prop('advancedsearch.js.map.zoomin'),
        zoomOutTitle: $.i18n.prop('advancedsearch.js.map.zoomout'),
    }).addTo(map);
}
