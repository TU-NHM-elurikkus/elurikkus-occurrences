var ColourByControl = L.Control.extend({
    options: {
        position: 'topright',
        collapsed: false
    },

    onAdd: function (map) {
        // create the control container with a particular class name
        var $controlToAdd = $('.colourbyTemplate').clone();

        var container = L.DomUtil.create('div', 'leaflet-control-layers');
        var $container = $(container);

        $container.attr('id','colourByControl');
        $container.attr('aria-haspopup', true);
        $container.html($controlToAdd.html());

        return container;
    }
});

var RecordLayerControl = L.Control.extend({
    options: {
        position: 'topright',
        collapsed: false
    },

    onAdd: function (map) {
        // create the control container with a particular class name
        var container = L.DomUtil.create('div', 'leaflet-control-layers');
        var $container = $(container);

        $container.attr('id','recordLayerControl');
        $('#mapLayerControls').prependTo($container);

        // Fix for Firefox select bug
        var stop = L.DomEvent.stopPropagation;

        L.DomEvent
            .on(container, 'click', stop)
            .on(container, 'mousedown', stop);

        return container;
    }
});

// props :: {
//      mappingUrl, query, queryDisplayString,
//      defaultZoom, overlays, baseLayer, zoomOutsideScopdRegions, pointColour,
//      contextPath, translations, biocacheServiceURL, wkt
// }
function OccurrenceMap(query, props) {
    this.map = null;
    this.query = query;
    this.props = props;

    this.baseLayers = {
        'Minimal': props.baseLayer,
    };

    this.layerControl = null;
    this.currentLayers = [];

    this.additionalFqs = '';
    this.removeFqs = '';

    this.clickCount = 0;

    this.uiOptions = {
        pointSize: $('#sizeslider-val').html(),
        opacity: $('#opacityslider-val').html(),
        outline: $('#outlineDots').is(':checked'),
        colorModeCode: $('#ta-grid-color-mode').val()
    };
}

OccurrenceMap.prototype.initialize = function() {
    var self = this;

    if(self.map !== null) {
        return;
    }

    // initialise map
    self.map = L.map('leafletMap', {
        center: self.props.center,

        zoom: self.props.defaultZoom,
        minZoom: 1,
        scrollWheelZoom: false,

        zoomControl: false,

        fullscreenControl: true,
        fullscreenControlOptions: {
            position: 'topleft'
        },

        worldCopyJump: true
    });

    addZoomControl(self.map);

    // add edit drawing toolbar
    // Initialise the FeatureGroup to store editable layers
    self.drawnItems = new L.FeatureGroup();
    self.map.addLayer(self.drawnItems);

    // Initialise the draw control and pass it the FeatureGroup of editable layers
    self.drawControl = new L.Control.Draw({
        edit: {
            featureGroup: self.drawnItems
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
    self.map.addControl(self.drawControl);

    self.map.on('draw:created', function(e) {
        //setup onclick event for self object
        var layer = e.layer;
        addClickEventForVector(layer, self.query, self.map);
        generatePopup(layer, e.latlng, self.query, self.map);
        self.drawnItems.addLayer(layer);
    });

    //add the default base layer
    self.map.addLayer(defaultBaseLayer);

    L.control.coordinates({position:"bottomright", useLatLngOrder: true}).addTo(self.map); // coordinate plugin

    self.layerControl = L.control.layers(self.baseLayers, self.overlays, {collapsed:true, position:'topleft'});
    self.layerControl.addTo(self.map);

    self.addQueryLayer();

    self.map.addControl(new RecordLayerControl());
    self.map.addControl(new ColourByControl());

    L.Util.requestAnimFrame(self.map.invalidateSize, self.map, !1, self.map._container);
    L.Browser.any3d = false; // FF bug prevents selects working properly

    $('.colour-by-control').click(function(e){

        if($(this).parent().hasClass('leaflet-control-layers-expanded')){
            $(this).parent().removeClass('leaflet-control-layers-expanded');
            $('.colour-by-legend-toggle').show();
        } else {
            $(this).parent().addClass('leaflet-control-layers-expanded');
            $('.colour-by-legend-toggle').hide();
        }
        e.preventDefault();
        e.stopPropagation();
        return false;
    });

    // Don't bind in-place because it is used as an id for click events
    function pointLookupClickRegister(e) {
        return self.pointLookupClickRegister(e);
    }

    $('#colourByControl,#recordLayerControl').mouseover(function(e){
        //console.log('mouseover');
        self.map.dragging.disable();
        self.map.off('click', pointLookupClickRegister);
    });

    $('#colourByControl,#recordLayerControl').mouseout(function(e){
        //console.log('mouseout');
        self.map.dragging.enable();
        self.map.on('click', pointLookupClickRegister);
    });

    $('.hideColourControl').click(function(e){
        //console.log('hideColourControl');
        $('#colourByControl').removeClass('leaflet-control-layers-expanded');
        $('.colour-by-legend-toggle').show();
        e.preventDefault();
        e.stopPropagation();
        return false;
    });

    $( "#sizeslider" ).slider({
        min:1,
        max:6,
        value: Number($('#sizeslider-val').text()),
        tooltip: 'hide'
    }).on('slideStop', function(ev){
        self.uiOptions.pointSize = ev.value;
        $('#sizeslider-val').html(ev.value);

        self.addQueryLayer();
    });

    $( "#opacityslider" ).slider({
        min: 0.1,
        max: 1.0,
        step: 0.1,
        value: Number($('#opacityslider-val').text()),
        tooltip: 'hide'
    }).on('slideStop', function(ev){
        var value = parseFloat(ev.value).toFixed(1); // prevent values like 0.30000000004 appearing

        self.uiOptions.opacity = value;
        $('#opacityslider-val').html(value);

        if(self.mode) {
            self.mode.setOpacity(value);
        } else {
            self.addQueryLayer();
        }
    });

    $('#outlineDots').click(function(e) {
        self.uiOptions.outline = $('#outlineDots').is(':checked');

        self.addQueryLayer();
    });

    $('#ta-grid-color-mode').change(function(e) {
        self.uiOptions.colorModeCode = e.target.value;

        if(self.mode) {
            self.mode.updateStyle();
        }
    });

    self.fitMapToBounds(); // zoom map if points are contained within Australia
    //drawCircleRadius(); // draw circle around lat/lon/radius searches

    // display vector from previous wkt search
    if(self.wkt) {
        var wkt = new Wkt.Wkt();
        wkt.read(self.wkt);
        var wktObject = wkt.toObject({color: '#bada55'});
        wktObject.on('click', pointLookupClickRegister);
        self.drawnItems.addLayer(wktObject);

    } else if (isSpatialRadiusSearch()) {
        // draw circle onto map
        var circle = L.circle([$.url().param('lat'), $.url().param('lon')], ($.url().param('radius') * 1000), {color: '#bada55'});
        circle.on('click', pointLookupClickRegister);
        self.drawnItems.addLayer(circle);
    }

    self.map.on('draw:edited', function(e) {
        //setup onclick event for self object
        var layers = e.layers;
        layers.eachLayer(function (layer) {
            addClickEventForVector(layer, self.query, self.map);
        });
    });

    self.map.on('click', pointLookupClickRegister);
}

/**
 * A tile layer to map colouring the dots by the selected colour.
 */
OccurrenceMap.prototype.addQueryLayer = function() {
    var self = this;

    self.clearLayers();

    if(self.mode) {
        self.mode.destroy();
    }

    var colourByFacet = $('#colourBySelect').val();

    if(colourByFacet && colourByFacet === 'taimeatlasGrid') {
        self.mode = new TaimeatlasMode(self);
    } else {
        self.mode = new ColorMode(self, colourByFacet);
    }

    self.mode.initialize();

    return true;
}

OccurrenceMap.prototype.clearLayers = function() {
    var self = this;

    $.each(self.currentLayers, function(index, value){
        self.map.removeLayer(self.currentLayers[index]);
        self.layerControl.removeLayer(self.currentLayers[index]);
    });

    self.currentLayers = [];
}

/**
 * Fudge to allow double clicks to propagate to map while allowing single clicks to be registered
 *
 */
OccurrenceMap.prototype.pointLookupClickRegister = function(e) {
    this.clickCount += 1;

    if(this.clickCount <= 1) {
        setTimeout(function() {
            if (this.clickCount <= 1) {
                this.pointLookup(e);
            }

            this.clickCount = 0;
        }.bind(this), 400);
    }
}

var ZOOM_TO_RADIUS = [
    800, 400, 200, 100, 50, 25, 20, 7.5, 3, 1.5,
    0.75, 0.25, 0.1, 0.05, 0.025, 0.015, 0.0075, 0.004, 0.002, 0.001
]

OccurrenceMap.prototype.pointLookup = function(e) {
    return this.mode.click(e);
}

OccurrenceMap.prototype.changeFacetColours = function() {
    this.additionalFqs = '';
    // clear this variable every time a new colour by is chosen.
    this.removeFqs = ''

    this.addQueryLayer();

    return true;
}

// TODO: Is this used anywhere
function showHideControls(el) {
    //console.log("el", el, this);
    var $this = this;
    if ($($this).hasClass('fa')) {
        alert("activating");
        $($this).hide();
        $($this + ' table.controls').show();
    } else {
        alert("deactivating");
        $($this).show();
        $($this + ' table.controls').hide();
    }
}

function addDefaultLegendItem(pointColour){
    $(".legendTable")
        .append($('<tr>')
            .append($('<td>')
                .append($('<i>')
                    .addClass('legendColour')
                    .attr('style', "background-color:#"+ pointColour + ";")
                    .attr('id', 'defaultLegendColour')
                )
                .append($('<span>')
                    .addClass('legendItemName')
                    .html("All records")
                )
            )
        );
}

OccurrenceMap.prototype.addGridLegendItem = function() {
    $(".legendTable")
        .append($('<tr>')
            .append($('<td>')
                .append($('<img id="gridLegendImg" src="' + this.props.mappingUrl + '/density/legend' + this.query + '"/>'))
            )
        );
}

/*
 * Helper for addLegendItem as that recieves its label as a dynamic message string
 * and those messages aren't always translated
 */
function getLegendLabel(name) {
    if(name in $.i18n.map) {
        return $.i18n.prop(name);
    }
    var label = name.split('.');
    label = label[label.length - 1];
    label = label.match(/[A-Za-z][a-z,]*/g);

    return label.map(function (word) {
        return word.charAt(0).toUpperCase() + word.substring(1);
    }).join(" ");
}

function addLegendItem(name, red, green, blue, data){
    var nameLabel = getLegendLabel(name);
    var isoDateRegEx = /^(\d{4})-\d{2}-\d{2}T.*/; // e.g. 2001-02-31T12:00:00Z with year capture
    if (name.search(isoDateRegEx) > -1) {
        // convert full ISO date to YYYY-MM-DD format
        name = name.replace(isoDateRegEx, "$1");
    }
    $(".legendTable")
        .append($('<tr>')
            .append($('<td>')
                .append($('<input>')
                    .attr('type', 'checkbox')
                    .attr('checked', 'checked')
                    .attr('id', name)
                    .attr('fq', data.fq)
                    .addClass('layerFacet')
                    .addClass('leaflet-control-layers-selector')
                )
            )
            .append($('<td>')
                .append($('<i>')
                    .addClass('legendColour')
                    .attr('style', 'background-color:rgb(' + red + ',' + green + ',' + blue + ');')
                )
                .append($('<span>')
                    .addClass('legendItemName')
                    .html(nameLabel)
                )
            )
        );
}

function rgbToHex(redD, greenD, blueD){
    var red = parseInt(redD);
    var green = parseInt(greenD);
    var blue = parseInt(blueD);

    var rgb = blue | (green << 8) | (red << 16);
    return rgb.toString(16);
}

// XXX TODO: Normally
OccurrenceMap.prototype.formatPopupHtml = function(record) {
    var ts = this.props.translations;

    var displayHtml = '';
    // catalogNumber
    if(record.raw.occurrence.catalogNumber) {
        displayHtml += '<b>' + ts['record.catalogNumber.label'] + ':</b> ' + record.raw.occurrence.catalogNumber + '<br />';
    } else if(record.processed.occurrence.catalogNumber) {
        displayHtml += '<b>' + ts['record.catalogNumber.label'] + ':</b> ' + record.processed.occurrence.catalogNumber + '<br />';
    }

    // record or field number
    if(record.raw.occurrence.recordNumber) {
        displayHtml += '<b>' + ts['record.recordNumber.label'] + ':</b> ' + record.raw.occurrence.recordNumber + '<br />';
    } else if(record.raw.occurrence.fieldNumber) {
        displayHtml += '<b>' + ts['record.fieldNumber.label'] + ':</b> ' + record.raw.occurrence.fieldNumber + '<br />';
    }

    if(record.raw.classification.vernacularName) {
        displayHtml += record.raw.classification.vernacularName + '<br />';
    } else if(record.processed.classification.vernacularName) {
        displayHtml += record.processed.classification.vernacularName + '<br />';
    }

    if(record.processed.classification.scientificName) {
        displayHtml += formatSciName(record.processed.classification.scientificName, record.processed.classification.taxonRankID) + '<br />';
    } else {
        displayHtml += record.raw.classification.scientificName + '<br />';
    }

    if(record.processed.attribution.institutionName) {
        displayHtml += '<b>' + ts['record.institutionName.label'] + ':</b> ' + record.processed.attribution.institutionName + '<br />';
    } else if(record.processed.attribution.dataResourceName) {
        displayHtml += '<b>' + ts['record.dataResourceName.label'] + ':</b> ' + record.processed.attribution.dataResourceName + '<br />';
    }

    if(record.processed.attribution.collectionName) {
        displayHtml += '<b>' + ts['record.collectionName.label'] + ':</b> ' + record.processed.attribution.collectionName + '<br />';
    }

    if(record.raw.occurrence.recordedBy) {
        displayHtml += '<b>' + ts['record.recordedBy.label'] + ':</b> ' + record.raw.occurrence.recordedBy + '<br />';
    } else if(record.processed.occurrence.recordedBy) {
        displayHtml += '<b>' + ts['record.recordedBy.label'] + ':</b> ' + record.processed.occurrence.recordedBy + '<br />';
    }

    if(record.processed.event.eventDate) {
        var label = '<b>' + ts['record.eventDate.label'] + ':</b> ';
        displayHtml += label + record.processed.event.eventDate;
    }

    return displayHtml;
};

OccurrenceMap.prototype.getRecordInfo = function() {
    // http://biocache.ala.org.au/ws/occurrences/c00c2f6a-3ae8-4e82-ade4-fc0220529032
    $.ajax({
        url: this.props.biocacheServiceURL + "/occurrences/info" + this.query,
        jsonp: "callback",
        dataType: "jsonp",
        success: function(response) {
        }
    });
}

/**
 * Format the display of a scientific name.
 * E.g. genus and below should be italicised
 */
function formatSciName(name, rankId) {
    var output = "";

    if (rankId && rankId >= 6000) {
        output = "<i>" + name + "</i>";
    } else {
        output = name;
    }
    return output;
}

/**
 * Zooms map to either spatial search or from WMS data bounds
 */
OccurrenceMap.prototype.fitMapToBounds = function() {
    // do webservice call to get max extent of WMS data
    var jsonUrl = this.props.biocacheServiceURL + "/mapping/bounds.json" + this.query + "&callback=?";

    $.getJSON(jsonUrl, function(data) {
        if (data.length == 4) {
            var sw = L.latLng(data[1],data[0]);
            var ne = L.latLng(data[3],data[2]);
            var dataBounds = L.latLngBounds(sw, ne);
            var mapBounds = this.map.getBounds();

            if (mapBounds && mapBounds.contains(sw) && mapBounds.contains(ne) && dataBounds) {
                // data bounds is smaller than the default map bounds/view, so zoom into fit data
                this.map.fitBounds(dataBounds);

                if (this.map.getZoom() > 15) {
                    this.map.setZoom(15);
                }
            } else if (!mapBounds.contains(dataBounds) && !mapBounds.intersects(dataBounds)) {
                // if data is not present in the default map bounds/view, then zoom to data
                this.map.fitBounds(dataBounds);
                if (this.map.getZoom() > 3) {
                    this.map.setZoom(3);
                }
            } else if (this.zoomOutsideScopedRegion) {
                // if data is present in default map view but also outside that area, then zoom to data bounds
                // as long as zoomOutsideScopedRegion is true, otherwise keep default zoom/bounds

                // fitBounds is async so we set a one time only listener to detect change
                this.map.once('zoomend', function() {
                    //console.log("zoomend", this.map.getZoom());
                    if (this.map.getZoom() < 2) {
                        this.map.setView(L.latLng(0, 24), 2); // zoom level 2 and centered over africa
                    }
                });
                this.map.fitBounds(dataBounds);
            }
            this.map.invalidateSize();
        }
    }.bind(this));
}

/**
 * Spatial searches from Explore Your Area - draw a circle representing
 * the radius boundary for the search.
 *
 * Note: this function has a dependency on purl.js:
 * https://github.com/allmarkedup/purl
 */
OccurrenceMap.prototype.drawCircleRadius = function() {
    if (isSpatialRadiusSearch()) {
        // spatial search from EYA
        var lat = $.url().param('lat');
        var lng = $.url().param('lon');
        var radius = $.url().param('radius');
        var latLng = L.latLng(lat, lng);
        var circleOpts = {
            weight: 1,
            color: 'white',
            opacity: 0.5,
            fillColor: '#222', // '#2C48A6'
            fillOpacity: 0.2
        }

        L.Icon.Default.imagePath = this.contextPath + "/static/js/leaflet-0.7.2/images";

        var popupText = "Centre of spatial search with radius of " + radius + " km";

        var circle = L.circle(latLng, radius * 1030, circleOpts);
        circle.addTo(this.map);
        // make circle the centre of the map, not the points
        this.map.fitBounds(circle.getBounds());

        L.marker(latLng, {title: popupText}).bindPopup(popupText).addTo(this.map);
        this.map.invalidateSize();
    }
}

/**
 * Returns true for a lat/lon/radius (params) style search
 *
 * @returns {boolean}
 */
function isSpatialRadiusSearch() {
    var lat = $.url().param('lat');
    var lng = $.url().param('lon');
    var radius = $.url().param('radius');

    return Boolean(lat && lng && radius);
}

/* Map modes */
function MapMode(map) {
    this.map = map;
}

MapMode.prototype.initialize = function() {
}

MapMode.prototype.click = function(e) {
}

MapMode.prototype.setOpacity = function(opacity) {
}

// XXX: Used only for TA mode, because the normal one can't change styles (beside opacity)
// without needing to be recreated
//
// TODO: Think how to unify those properly
MapMode.prototype.updateStyle = function() {
}

MapMode.prototype.destroy = function() {
}

/* Color mode: included in ALA, uses biocache-service to plot points colored by some facet
 * or render a grid
 */
function ColorMode(map, facet) {
    MapMode.call(this, map);

    this.facet = facet;
}

ColorMode.prototype = Object.create(MapMode.prototype);

ColorMode.prototype.initialize = function() {
    var self = this;

    var layer;

    function reinitLayer() {
        var pointSize = self.map.uiOptions.pointSize;
        var opacity = self.map.uiOptions.opacity;
        var outlineDots = self.map.uiOptions.outline;

        var envProperty = "color:" + self.map.props.pointColour + ";nam:circle;size:" + pointSize + ";opacity:" + opacity;

        if(self.facet){
            if(self.facet == "gridVariable"){
                self.facet = "coordinate_uncertainty"
                envProperty = "colormode:coordinate_uncertainty;name:circle;size:" + pointSize + ";opacity:1;cellfill:0xffccff;variablegrids:on"
            } else {
                envProperty = "colormode:" + self.facet + ";name:circle;size:" + pointSize + ";opacity:1;"
            }
        }

        var gridSizeMap = {
            1: 256, 2:128, 3: 64, 4:32, 5:16, 6:8
        }

        layer = L.tileLayer.wms(self.map.props.mappingUrl + "/mapping/wms/reflect" + self.map.query + self.map.additionalFqs, {
            layers: 'ALA:occurrences',
            format: 'image/png',
            transparent: true,
            bgcolor:"0x000000",
            outline:outlineDots,
            ENV: envProperty,
            opacity: opacity,
            GRIDDETAIL: gridSizeMap[pointSize],
            STYLE: "opacity:" + opacity // for grid data
        });

        self.layer = layer;

        self.map.layerControl.addOverlay(layer, 'Occurrences');
        self.map.map.addLayer(layer);
        self.map.currentLayers.push(layer);
    }

    function initLayerFacet() {
        $('.layerFacet').click(function(e){
            var controlIdx = 0;
            self.map.additionalFqs = '';
            self.map.removeFqs = ''

            $('#colourByControl').find('.layerFacet').each(function(idx, layerInput){
                var $input = $(layerInput), fq;
                var include =  $input.is(':checked');

                if(!include){
                    self.map.additionalFqs = self.map.additionalFqs + '&HQ=' + controlIdx;
                    fq = $input.attr('fq');
                    // logic for facets with missing value is different from those with value
                    if(fq && fq.startsWith('-')){
                        // to ignore unknown or missing values, minus sign must be removed
                        fq = fq.replace('-','');
                    } else{
                        // for all other values minus sign has to be added
                        fq = '-' + fq;
                    }

                    // add fq to ensure the query in sync with dots displayed on map
                    self.map.removeFqs += '&fq=' + fq;
                }
                controlIdx = controlIdx + 1;

                self.map.clearLayers();
                reinitLayer();
            });
        });
    }

    function initLegend() {
        $('.legendTable').html('');

        if(!self.facet){
            addDefaultLegendItem(self.map.props.pointColour);
        } else if (self.facet == 'grid') {
            self.map.addGridLegendItem();
        } else {
            //update the legend
            var pageSize = 20;
            var pageNum = 0;

            var loadMoreButton = $('#legendLoadMore');

            function updateLegend(data) {
                $.each(data, function(index, legendDef){
                    var legItemName = legendDef.name ? legendDef.name : 'recordcore.record.value.unspecified';

                    addLegendItem(legItemName, legendDef.red, legendDef.green, legendDef.blue, legendDef );
                });
            }

            function loadMoreLegend(onDone) {
                loadMoreButton.addClass('hidden-node');

                pageNum++;

                $.ajax({
                    url: self.map.props.contextPath + '/occurrence/legend' + self.map.query +
                        '&cm=' + self.facet +
                        '&pageNum=' + pageNum +
                        '&pageSize=' + pageSize +
                        '&type=application/json',
                    success: function(data) {
                        updateLegend(data);

                        if(data.length ===  pageSize) {
                            loadMoreButton.removeClass('hidden-node');
                        }

                        if(onDone) {
                            onDone();
                        }
                    }
                });
            }

            loadMoreButton.off('click');
            loadMoreButton.on('click', function() {
                // Wrapped so that click event doesn't get passed
                loadMoreLegend()
            });

            loadMoreLegend(initLayerFacet);
        }
    }

    reinitLayer();
    initLegend();
}

ColorMode.prototype.click = function(e) {
    // TODO: Should just be a function
    var popup = new ColorMapPopup(this.map, e);

    popup.initialise();
}

ColorMode.prototype.setOpacity = function(opacity) {
    this.layer.setOpacity(opacity);
}

/* Taimeatlas mode: renders TA grid and allows querying occurrences by square */
function TaimeatlasMode(map) {
    MapMode.call(this, map);
}

TaimeatlasMode.prototype = Object.create(MapMode.prototype);

var GRID_COLOR_MODES = (function() {
    var MIN_INTENSITY = 0;
    var MAX_INTENSITY = 255;

    function rgbToCSS(r, g, b) {
        return 'rgb(' + r + ', ' + g + ', ' + b + ')';
    }

    function getFrequency(count, min, max) {
        return (count - min) / (max - min);
    }

    function getBounds(counts) {
        var min = Infinity;
        var max = -Infinity;

        counts.forEach(function(square) {
            min = Math.min(min, square.count);
            max = Math.max(max, square.count);
        });

        return {
            min: min,
            max: max
        };
    }

    function linear(counts) {
        var bounds = getBounds(counts);

        return function(count) {
            var frequency = getFrequency(count, bounds.min, bounds.max);
            var intensity = Math.round(MIN_INTENSITY + (1 - frequency) * (MAX_INTENSITY - MIN_INTENSITY)).toString();

            return rgbToCSS(255, intensity, 0);
        }
    }

    function logscale(counts) {
        var bounds = getBounds(counts);

        return function(count) {
            var frequency = Math.log(count - bounds.min + 1) / Math.log(bounds.max - bounds.min + 1);
            var intensity = Math.round(MIN_INTENSITY + (1 - frequency) * (MAX_INTENSITY - MIN_INTENSITY)).toString();

            return rgbToCSS(255, intensity, 0);
        }
    }

    function quantile(counts, quantileNum) {
        // Calculate quantiles
        if(quantileNum === undefined) {
            quantileNum = Math.min(counts.length, 10);
        }

        var sortedCounts = counts.map(function(region) {
            return region.count;
        }).sort(function(a, b) {
            return a - b;
        });

        var breakpoints = [];

        var quantileSize = Math.floor(sortedCounts.length / quantileNum);

        for(var i = 0; i < quantileNum - 1; i++) {
            breakpoints[i] = sortedCounts[(i + 1) * quantileSize];
        }

        breakpoints[quantileNum - 1] = sortedCounts[sortedCounts.length - 1];

        // Assign a color to each quantile
        var colors = [];

        for(var j = 0; j < quantileNum; j++) {
            var intensity = Math.round(MIN_INTENSITY + (1 - j / (quantileNum - 1)) * (MAX_INTENSITY - MIN_INTENSITY));

            colors[j] = rgbToCSS(255, intensity, 0);
        }

        return function(count) {
            var quantile = 0;

            while(quantile < quantileNum && breakpoints[quantile] < count) {
                quantile++;
            }

            return colors[quantile];
        }
    }

    return {
        linear: linear,
        logscale: logscale,
        quantile: quantile
    };
})();

TaimeatlasMode.prototype.queryCounts = function(callback) {
    var url = this.map.props.contextPath + '/proxy/occurrence/facets' + this.map.query + '&facets=cl1008&flimit=1000';

    $.getJSON(url, function(response) {
        callback(response[0].fieldResult.filter(function(square) {
            return square.label != '';
        }));
    });
}

TaimeatlasMode.prototype.loadGeometry = function(counts, callback) {
    var idToCount = {};

    counts.forEach(function(square) {
        idToCount[square.label] = square.count;
    });

    $.getJSON(this.map.props.contextPath + '/data/taimeatlase_ruudud.json', function(squares) {
        squares.features.forEach(function(square) {
            square.properties.count = idToCount[square.properties.ruudu_kood];
        });

        squares.features = squares.features.filter(function(square) {
            return square.properties.count > 0;
        });

        callback(squares);
    });
}

TaimeatlasMode.prototype.initialize = function() {
    var self = this;

    self.queryCounts(function(counts) {
        self.counts = counts;

        self.loadGeometry(counts, function(geometry) {
            var opacity = self.map.uiOptions.opacity;
            var outline = self.map.uiOptions.outline;
            var colorModeCode = self.map.uiOptions.colorModeCode;

            // TODO: count-based styling?
            var layer = L.geoJson(geometry, {
                style: self.createStyle(opacity, outline, colorModeCode),
                onEachFeature: function(feature, layer) {
                    layer.on('click', function(e) {
                        self.showPopup(e, feature);
                    });
                }
            });

            self.layer = layer;

            self.map.layerControl.addOverlay(layer, 'Taimatlas grid');
            self.map.map.addLayer(layer);
            self.map.currentLayers.push(layer);

            $('#ta-grid-color-mode').removeClass('hidden-node');
        });
    });
};

TaimeatlasMode.prototype.showPopup = function(e, feature) {
    var popup = new TaimeatlasMapPopup(this.map, e, feature);
    popup.initialise();
};

TaimeatlasMode.prototype.click = function(e) {
};

TaimeatlasMode.prototype.createStyle = function(opacity, outline, colorModeCode) {
    var colorMode = GRID_COLOR_MODES[colorModeCode](this.counts);

    return function(feature) {
        return {
            color: 'rgb(0, 0, 0)',
            fillColor: colorMode(feature.properties.count),
            fillOpacity: opacity,
            weight: outline ? 1 : 0
        };
    };
};

TaimeatlasMode.prototype.setOpacity = function(opacity) {
    this.updateStyle();
};

TaimeatlasMode.prototype.updateStyle = function() {
    // Layer is initialised async, so need to guard
    if(this.layer) {
        var opacity = this.map.uiOptions.opacity;
        var outline = this.map.uiOptions.outline;
        var colorModeCode = this.map.uiOptions.colorModeCode;

        this.layer.setStyle(this.createStyle(opacity, outline, colorModeCode));
    }
};

TaimeatlasMode.prototype.destroy = function() {
    $('#ta-grid-color-mode').addClass('hidden-node');
};

function MapPopup(map) {
    this.map = map;
    this.currentIdx = 0;
    this.total = 0;
    this.uuids = [];
}

// Do the initial load, create popup
MapPopup.prototype.initialise = function() {
};

MapPopup.prototype.next = function() {
    if(this.currentIdx < this.total - 1) {
        this.switchOccurrence(this.currentIdx + 1);
    }
};

MapPopup.prototype.previous = function() {
    if(this.currentIdx > 0) {
        this.switchOccurrence(this.currentIdx - 1);
    }
};

MapPopup.prototype.changeIndex = function(idx) {
    this.currentIdx = idx;

    this.$popupClone.find('button.nextRecord').toggleClass('disabled', idx >= this.total - 1);
    this.$popupClone.find('button.previousRecord').toggleClass('disabled', idx <= 0);

    this.$popupClone.find('.currentRecord').html(idx + 1);
};

// Create popup and insert it into DOM
MapPopup.prototype.createElement = function() {
    var $popupClone = $('.popupRecordTemplate').clone();

    // header
    $popupClone.find('.multiRecordHeader').show();
    $popupClone.find('.currentRecord').html(this.currentIdx + 1);
    $popupClone.find('.totalrecords').html(this.total.toString());

    $popupClone.find('a.viewAllRecords').attr('href', this.getViewAllLink());

    // footer
    $popupClone.find('.multiRecordFooter').show();

    $popupClone.find('button.nextRecord').click(function() {
        this.next();
    }.bind(this));

    $popupClone.find('button.previousRecord').click(function() {
        this.previous();
    }.bind(this));

    this.$popupClone = $popupClone;

    this.map.popup = L.popup().setLatLng(this.event.latlng);

    this.map.popup.setContent(this.$popupClone[0]);
    this.map.popup.openOn(this.map.map);
};

MapPopup.prototype.getViewAllLink = function() {
    return 'http://example.com';
};

// Takes full occurrence info and shows in the popup
MapPopup.prototype.showOccurrence = function(record) {
    var html = this.map.formatPopupHtml(record);

    this.$popupClone.find('.recordSummary').html(html);

    if(record.raw) {
        html = this.map.formatPopupHtml(record);
        this.$popupClone.find('.recordSummary').html(html);

        this.$popupClone.find('a.recordLink').attr('href', this.map.props.contextPath + '/occurrences/' + record.raw.uuid);
        this.$popupClone.find('a.recordLink').attr('disabled', false);
    } else {
        // missing record - disable "view record" button and display message
        this.$popupClone.find('a.recordLink').attr('disabled', true).attr('href', 'javascript: void(0)');
        // insert into clone
        this.$popupClone.find('.recordSummary').html('<br>' + this.map.props.translations['search.recordNotFoundForId'] + ': <span style="white-space:nowrap;">' + recordUuid + '</span><br><br>');
    }
};

// Switches to occurrence # idx
MapPopup.prototype.switchOccurrence = function(idx) {
    var self = this;

    self.map.map.spin(true);

    if(idx < self.uuids.length) {
        var currentIdx = self.currentIdx;

        self.loadOccurrence(self.uuids[idx], function(data) {
            if(self.currentIdx == currentIdx) {
                self.showOccurrence(data);
                self.changeIndex(idx);
                self.map.map.spin(false);
            }
        });
    } else if(idx < self.total) {
        self.loadMore(function() {
            self.switchOccurrence(idx);
            self.map.map.spin(false);
        }.bind(self));
    } else {
        self.map.map.spin(false);
    }
}

// Loads occurrence data
MapPopup.prototype.loadOccurrence = function(uuid, callback) {
    $.getJSON(this.map.props.contextPath + '/proxy/occurrences/' + uuid + '.json', callback);
}

MapPopup.prototype.loadMore = function(callback) {
}

function ColorMapPopup(map, event) {
    MapPopup.call(this, map);

    this.event = event;
}

ColorMapPopup.prototype = Object.create(MapPopup.prototype);

ColorMapPopup.prototype.initialise = function() {
    var self = this;
    var map = self.map;

    var mapQuery = map.query.replace(/&(?:lat|lon|radius)\=[\-\.0-9]+/g, '');
    var radius = this.getPopupRadius();

    map.map.spin(true);

    $.ajax({
        url: map.props.mappingUrl + "/occurrences/info" + mapQuery + map.removeFqs,
        jsonp: "callback",
        dataType: "jsonp",
        timeout: 30000,

        data: {
            zoom: map.map.getZoom(),
            lat: self.event.latlng.wrap().lat,
            lon: self.event.latlng.wrap().lng,
            radius: radius,
            format: "json"
        },

        success: function(response) {
            map.map.spin(false);

            if (response.occurrences && response.occurrences.length > 0) {
                self.uuids = response.occurrences;
                self.total = self.uuids.length;

                self.createElement();

                self.switchOccurrence(0);
            }
        },

        error: function() {
            map.map.spin(false);
        }
    });
}

ColorMapPopup.prototype.getPopupRadius = function() {
    var radius = 0;
    var size = this.map.uiOptions.pointSize;
    var zoomLevel = this.map.map.getZoom();

    radius = ZOOM_TO_RADIUS[zoomLevel];

    if (size >= 5 && size < 8){
        radius = radius * 2;
    }

    if (size >= 8){
        radius = radius * 3;
    }

    return radius;
}

ColorMapPopup.prototype.getViewAllLink = function() {
    var lat = this.event.latlng.lat;
    var lon = this.event.latlng.lng;
    var radius = this.getPopupRadius();

    var occLookup = "&radius=" + radius + "&lat=" + lat + "&lon=" + lon;
    var sanitizedQuery = this.map.query.replace(/&(?:lat|lon|radius)\=[\-\.0-9]+/g, '');

    return this.map.props.contextPath + '/occurrences/search' + sanitizedQuery + occLookup;
}

function TaimeatlasMapPopup(map, event, feature) {
    MapPopup.call(this, map);

    this.event = event;
    this.feature = feature;

    this.total = feature.properties.count;

    this.loadMoreCallbacks = [];
}

TaimeatlasMapPopup.prototype = Object.create(MapPopup.prototype);

TaimeatlasMapPopup.prototype.initialise = function() {
    var self = this;
    var map = self.map;

    var popup = L.popup().setLatLng(self.event.latlng);

    self.loadPage(0, function(uuids) {
        self.uuids = uuids;
        self.currentPage = 0;

        self.createElement();
        self.switchOccurrence(0);
    });
}

TaimeatlasMapPopup.prototype.loadPage = function(page, callback) {
    var pageSize = 10;
    var mapQuery = this.map.query.replace(/&(?:lat|lon|radius)\=[\-\.0-9]+/g, '');

    $.getJSON(this.map.props.contextPath + '/proxy/occurrences/search' + mapQuery, {
        fq: 'cl1008:"' + this.feature.properties.ruudu_kood + '"',
        facet: 'off',
        pageSize: pageSize,
        start: page * pageSize
    }, function(results) {
        callback(results.occurrences.map(function(occ) {
            return occ.uuid;
        }));
    });
}

TaimeatlasMapPopup.prototype.getViewAllLink = function() {
    var fq = 'cl1008:"' + this.feature.properties.ruudu_kood + '"';

    return this.map.props.contextPath + '/occurrences/search' + this.map.query + '&fq=' + fq;
}

TaimeatlasMapPopup.prototype.loadMore = function(callback) {
    var self = this;

    var alreadyLoading = self.loadMoreCallbacks.length > 0;

    self.loadMoreCallbacks.push(callback);

    if(!alreadyLoading) {
        self.loadPage(self.currentPage + 1, function(uuids) {
            self.uuids = self.uuids.concat(uuids);
            self.currentPage++;

            self.loadMoreCallbacks.forEach(function(callback) {
                callback();
            });

            self.loadMoreCallbacks = [];
        });
    }
}
