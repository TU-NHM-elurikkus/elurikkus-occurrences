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
        'Minimal' : props.baseLayer,
        'Road' :  new L.Google('ROADMAP'),
        'Terrain' : new L.Google('TERRAIN'),
        'Satellite' : new L.Google('HYBRID')
    };

    this.center = [58.67, 25.56];

    this.layerControl = null;
    this.currentLayers = [];

    this.additionalFqs = '';
    this.removeFqs = '';

    this.clickCount = 0;
}

OccurrenceMap.prototype.initialize = function() {
    var self = this;

    if(self.map != null){
        return;
    }

    //initialise map
    self.map = L.map('leafletMap', {
        center: self.props.center,

        zoom: self.props.defaultZoom,
        minZoom: 1,
        scrollWheelZoom: false,

        fullscreenControl: true,
        fullscreenControlOptions: {
            position: 'topleft'
        },

        worldCopyJump: true
    });

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
        generatePopup(layer, layer._latlng);
        addClickEventForVector(layer);
        self.drawnItems.addLayer(layer);
    });

    //add the default base layer
    self.map.addLayer(defaultBaseLayer);

    L.control.coordinates({position:"bottomright", useLatLngOrder: true}).addTo(self.map); // coordinate plugin

    self.layerControl = L.control.layers(self.baseLayers, self.overlays, {collapsed:true, position:'topleft'});
    self.layerControl.addTo(self.map);

    self.addQueryLayer(true);

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
        $('#sizeslider-val').html(ev.value);
        self.addQueryLayer(true);
    });

    $( "#opacityslider" ).slider({
        min: 0.1,
        max: 1.0,
        step: 0.1,
        value: Number($('#opacityslider-val').text()),
        tooltip: 'hide'
    }).on('slideStop', function(ev){
        var value = parseFloat(ev.value).toFixed(1); // prevent values like 0.30000000004 appearing
        $('#opacityslider-val').html(value);
        if (self.currentLayers.length == 1) {
            self.currentLayers[0].setOpacity(value);
        } else {
            self.addQueryLayer(true);
        }
    });

    $('#outlineDots').click(function(e) {
        self.addQueryLayer(true);
    });

    self.fitMapToBounds(); // zoom map if points are contained within Australia
    //drawCircleRadius(); // draw circle around lat/lon/radius searches

    // display vector from previous wkt search
    if(self.wkt) {
        var wkt = new Wkt.Wkt();
        wkt.read(self.wkt);
        var wktObject = wkt.toObject({color: '#bada55'});
        //addClickEventForVector(wktObject); // can't click on points if self is set
        //wktObject.editing.enable();
        wktObject.on('click', pointLookupClickRegister);
        self.drawnItems.addLayer(wktObject);

    } else if (isSpatialRadiusSearch()) {
        // draw circle onto map
        var circle = L.circle([$.url().param('lat'), $.url().param('lon')], ($.url().param('radius') * 1000), {color: '#bada55'});
        //console.log("circle", circle);
        //addClickEventForVector(circle);  // can't click on points if self is set
        circle.on('click', pointLookupClickRegister);
        self.drawnItems.addLayer(circle);
    }

    self.map.on('draw:edited', function(e) {
        //setup onclick event for self object
        var layers = e.layers;
        layers.eachLayer(function (layer) {
            generatePopup(layer, layer._latlng);
            addClickEventForVector(layer);
        });
    });

    self.recordList = new Array(); // store list of records for popup

    self.map.on('click', pointLookupClickRegister);
}

/**
 * A tile layer to map colouring the dots by the selected colour.
 */
OccurrenceMap.prototype.addQueryLayer = function(redraw) {
    var self = this;

    $.each(self.currentLayers, function(index, value){
        self.map.removeLayer(self.currentLayers[index]);
        self.layerControl.removeLayer(self.currentLayers[index]);
    });

    self.currentLayers = [];

    var colourByFacet = $('#colourBySelect').val();
    var pointSize = $('#sizeslider-val').html();
    var opacity = $('#opacityslider-val').html();
    var outlineDots = $('#outlineDots').is(':checked');

    var envProperty = "color:" + self.props.pointColour + ";nam:circle;size:" + pointSize + ";opacity:" + opacity;

    if(colourByFacet){
        if(colourByFacet == "gridVariable"){
            colourByFacet = "coordinate_uncertainty"
            envProperty = "colormode:coordinate_uncertainty;name:circle;size:" + pointSize + ";opacity:1;cellfill:0xffccff;variablegrids:on"
        } else {
            envProperty = "colormode:" + colourByFacet + ";name:circle;size:" + pointSize + ";opacity:1;"
        }
    }

    var gridSizeMap = {
        1: 256, 2:128, 3: 64, 4:32, 5:16, 6:8
    }

    var layer = L.tileLayer.wms(self.props.mappingUrl + "/mapping/wms/reflect" + self.query + self.additionalFqs, {
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

    if(redraw){
        if(!colourByFacet){
            $('.legendTable').html('');
            addDefaultLegendItem(self.props.pointColour);
        } else if (colourByFacet == 'grid') {
            $('.legendTable').html('');
            self.addGridLegendItem();
        } else {
            //update the legend
            $('.legendTable').html('<tr><td>Loading legend....</td></tr>');

            $.ajax({
                url: self.props.contextPath + '/occurrence/legend' + self.query + '&cm=' + colourByFacet + '&type=application/json',
                success: function(data) {
                    $('.legendTable').html('');

                    $.each(data, function(index, legendDef){
                        var legItemName = legendDef.name ? legendDef.name : 'Not specified';
                        addLegendItem(legItemName, legendDef.red,legendDef.green,legendDef.blue, legendDef );
                    });

                    $('.layerFacet').click(function(e){
                        var controlIdx = 0;
                        self.additionalFqs = '';
                        self.removeFqs = ''

                        $('#colourByControl').find('.layerFacet').each(function(idx, layerInput){
                            var $input = $(layerInput), fq;
                            var include =  $input.is(':checked');

                            if(!include){
                                self.additionalFqs = self.additionalFqs + '&HQ=' + controlIdx;
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
                                self.removeFqs += '&fq=' + fq;
                            }
                            controlIdx = controlIdx + 1;
                            self.addQueryLayer(false);
                        });
                    });
                }
            });
        }
    }

    self.layerControl.addOverlay(layer, 'Occurrences');
    self.map.addLayer(layer);
    self.currentLayers.push(layer);

    return true;
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
    this.popup = L.popup().setLatLng(e.latlng);

    var radius = 0;
    var size = $('sizeslider-val').html();
    var zoomLevel = this.map.getZoom();

    radius = ZOOM_TO_RADIUS[zoomLevel];

    if (size >= 5 && size < 8){
        radius = radius * 2;
    }

    if (size >= 8){
        radius = radius * 3;
    }

    this.popupRadius = radius;

    // remove existing lat/lon/radius/wkt params
    var mapQuery = this.query.replace(/&(?:lat|lon|radius)\=[\-\.0-9]+/g, '');

    this.map.spin(true);

    $.ajax({
        url: this.props.mappingUrl + "/occurrences/info" + mapQuery + this.removeFqs,
        jsonp: "callback",
        dataType: "jsonp",
        timeout: 30000,

        data: {
            zoom: this.map.getZoom(),
            lat: e.latlng.wrap().lat,
            lon: e.latlng.wrap().lng,
            radius: radius,
            format: "json"
        },

        success: function(response) {
            this.map.spin(false);

            if (response.occurrences && response.occurrences.length > 0) {

                this.recordList = response.occurrences; // store the list of record uuids
                this.popupLatlng = e.latlng.wrap(); // store the coordinates of the mouse click for the popup

                // Load the first record details into popup
                this.insertRecordInfo(0);
            }
        }.bind(this),

        error: function() {
            this.map.spin(false);
        }.bind(this),
    });
}
/**
 * Populate the map popup with record details
 *
 * @param recordIndex
 */
OccurrenceMap.prototype.insertRecordInfo = function(recordIndex) {
    var recordUuid = this.recordList[recordIndex];
    var $popupClone = $('.popupRecordTemplate').clone();

    this.map.spin(true);

    if (this.recordList.length > 1) {
        // populate popup header
        $popupClone.find('.multiRecordHeader').show();
        $popupClone.find('.currentRecord').html(recordIndex + 1);
        $popupClone.find('.totalrecords').html(this.recordList.length.toString().replace(/100/, '100+'));

        var occLookup = "&radius=" + this.popupRadius + "&lat=" + this.popupLatlng.lat + "&lon=" + this.popupLatlng.lng;
        var sanitizedQuery = this.query.replace(/&(?:lat|lon|radius)\=[\-\.0-9]+/g, '');
        var viewAllURL = this.props.contextPath + '/occurrences/search' + sanitizedQuery + occLookup;

        $popupClone.find('a.viewAllRecords').attr('href', viewAllURL);

        // populate popup footer
        $popupClone.find('.multiRecordFooter').show();

        // TODO: exorcise
        if (recordIndex < this.recordList.length - 1) {
            $popupClone.find('.nextRecord a').on('click', function() {
                this.insertRecordInfo(recordIndex + 1);
                return false;
            }.bind(this));

            $popupClone.find('.nextRecord a').removeClass('disabled');

            window.foo = $popupClone;
            window.bar = $popupClone.find('.nextRecord a');
        }

        if (recordIndex > 0) {
            $popupClone.find('.previousRecord a').on('click', function() {
                this.insertRecordInfo(recordIndex + 1);
                return false;
            }.bind(this));

            $popupClone.find('.previousRecord a').removeClass('disabled');
        }
    }

    $popupClone.find('.recordLink a').attr('href', this.props.contextPath + "/occurrences/" + recordUuid);

    // Get the current record details
    $.ajax({
        url: this.props.mappingUrl + "/occurrences/" + recordUuid + ".json",
        jsonp: "callback",
        dataType: "jsonp",

        success: function(record) {
            this.map.spin(false);

            if (record.raw) {
                var displayHtml = this.formatPopupHtml(record);
                $popupClone.find('.recordSummary').html( displayHtml ); // insert into clone
            } else {
                // missing record - disable "view record" button and display message
                $popupClone.find('.recordLink a').attr('disabled', true).attr('href','javascript: void(0)');
                // insert into clone
                $popupClone.find('.recordSummary').html( "<br>" + this.props.translations['search.recordNotFoundForId'] + ": <span style='white-space:nowrap;'>" + recordUuid + '</span><br><br>' );
            }

            this.popup.setContent($popupClone[0]);
            this.popup.openOn(this.map);
        }.bind(this),

        error: function() {
            this.map.spin(false);
        }.bind(this)
    });
}

OccurrenceMap.prototype.changeFacetColours = function() {
    this.additionalFqs = '';
    // clear this variable every time a new colour by is chosen.
    this.removeFqs = ''

    this.addQueryLayer(true);

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

function addLegendItem(name, red, green, blue, data){
    var nameLabel = jQuery.i18n.prop(name);
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
                    .attr('fq',data.fq)
                    .addClass('layerFacet')
                    .addClass('leaflet-control-layers-selector')
                )
            )
            .append($('<td>')
                .append($('<i>')
                    .addClass('legendColour')
                    .attr('style', "background-color:rgb("+ red +","+ green +","+ blue + ");")
                )
                .append($('<span>')
                    .addClass('legendItemName')
                    .html((nameLabel.indexOf("[") == -1) ? nameLabel : name)
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

    var displayHtml = "";

    // catalogNumber
    if(record.raw.occurrence.catalogNumber != null){
        displayHtml += ts['record.catalogNumber.label'] + ': ' + record.raw.occurrence.catalogNumber + '<br />';
    } else if(record.processed.occurrence.catalogNumber != null){
        displayHtml += ts['record.catalogNumber.label'] + ': ' + record.processed.occurrence.catalogNumber + '<br />';
    }

    // record or field number
    if(record.raw.occurrence.recordNumber != null){
        displayHtml += ts['record.recordNumber.label'] + ': ' + record.raw.occurrence.recordNumber + '<br />';
    } else if(record.raw.occurrence.fieldNumber != null){
        displayHtml += ts['record.fieldNumber.label'] + ': ' + record.raw.occurrence.fieldNumber + '<br />';
    }

    if(record.raw.classification.vernacularName!=null ){
        displayHtml += record.raw.classification.vernacularName + '<br />';
    } else if(record.processed.classification.vernacularName!=null){
        displayHtml += record.processed.classification.vernacularName + '<br />';
    }

    if (record.processed.classification.scientificName) {
        displayHtml += formatSciName(record.processed.classification.scientificName, record.processed.classification.taxonRankID)  + '<br />';
    } else {
        displayHtml += record.raw.classification.scientificName  + '<br />';
    }

    if(record.processed.attribution.institutionName != null){
        displayHtml += ts['record.institutionName.label'] + ': ' + record.processed.attribution.institutionName + '<br />';
    } else if(record.processed.attribution.dataResourceName != null){
        displayHtml += ts['record.dataResourceName.label'] + ': ' + record.processed.attribution.dataResourceName + '<br />';
    }

    if(record.processed.attribution.collectionName != null){
        displayHtml += ts['record.collectionName.label'] + ': ' + record.processed.attribution.collectionName  + '<br />';
    }

    if(record.raw.occurrence.recordedBy != null){
        displayHtml += ts['record.recordedBy.label']  + ': ' + record.raw.occurrence.recordedBy + '<br />';
    } else if(record.processed.occurrence.recordedBy != null){
        displayHtml += ts['record.recordedBy.label'] + ': ' + record.processed.occurrence.recordedBy + '<br />';
    }

    if(record.processed.event.eventDate != null){
        var label = ts['record.eventDate.label'] + ': ';
        displayHtml += label + record.processed.event.eventDate;
    }

    return displayHtml;
}

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
