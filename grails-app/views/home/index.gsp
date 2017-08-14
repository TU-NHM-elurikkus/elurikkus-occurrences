<%@ page import="org.springframework.web.servlet.support.RequestContextUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<g:set var="hubDisplayName" value="${grailsApplication.config.skin.orgNameLong}" />
<g:set var="biocacheServiceUrl" value="${grailsApplication.config.biocache.baseUrl}" />
<g:set var="serverName" value="${grailsApplication.config.serverName?:grailsApplication.config.biocache.baseUrl}" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="search" />
        <meta name="svn.revision" content="${meta(name: 'svn.revision')}" />

        <title>
            <g:message code="home.index.title" /> | ${hubDisplayName}
        </title>

        <script src="http://maps.google.com/maps/api/js?v=3.5&sensor=false"></script>

        <r:require modules="jquery, leafletOverride, leafletPluginsOverride, mapCommonOverride, searchMapOverride, bootstrapCombobox, menu" />

        <g:if test="${grailsApplication.config.skin.useAlaBie?.toBoolean()}">
            <r:require module="bieAutocomplete" />
        </g:if>

        <r:script>
            // global var for GSP tags/vars to be passed into JS functions
            var BC_CONF = {
                biocacheServiceUrl: "${alatag.getBiocacheAjaxUrl()}",
                bieWebappUrl: "${grailsApplication.config.bie.baseUrl}",
                bieWebServiceUrl: "${grailsApplication.config.bieService.baseUrl}",
                autocompleteHints: ${grailsApplication.config.bie?.autocompleteHints?.encodeAsJson()?:'{}'},
                contextPath: "${request.contextPath}",
                locale: "${RequestContextUtils.getLocale(request)}",
                queryContext: "${grailsApplication.config.biocache.queryContext}"
            }
            /*
             Leaflet, a JavaScript library for mobile-friendly interactive maps. http://leafletjs.com
             (c) 2010-2013, Vladimir Agafonkin
             (c) 2010-2011, CloudMade
             */
            /* Load Spring i18n messages into JS
             */
            jQuery.i18n.properties({
                name: 'messages',
                path: BC_CONF.contextPath + '/messages/i18n/',
                mode: 'map',
                language: BC_CONF.locale
            });

            $(document).ready(function() {
                var mapInit = false;

                $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {

                    var id = $(this).attr('id');

                    location.hash = 'tab-'+ $(e.target).attr('href').substr(1);

                    if (id == "t5" && !mapInit) {
                        initialiseMap();
                        mapInit = true;
                    }
                });

                // catch hash URIs and trigger tabs
                if (location.hash !== '') {
                    $('.nav-tabs a[href="' + location.hash.replace('tab-','') + '"]').tab('show');
                } else {
                    $('.nav-tabs a:first').tab('show');
                }

                // Toggle show/hide sections with plus/minus icon
                $(".toggleTitle").not("#extendedOptionsLink").click(function(e) {
                    e.preventDefault();
                    var $this = this;
                    $(this).next(".toggleSection").slideToggle('slow', function(){
                        // change plus/minus icon when transition is complete
                        $($this).toggleClass('toggleTitleActive');
                    });
                });

                $(".toggleOptions").click(function(e) {
                    e.preventDefault();
                    var $this = this;
                    var targetEl = $(this).attr("id");
                    $(targetEl).slideToggle('slow', function(){
                        // change plus/minus icon when transition is complete
                        $($this).toggleClass('toggleOptionsActive');
                    });
                });

                // Add WKT string to map button click
                $('#addWkt').click(function() {
                    var wktString = $('#wktInput').val();

                    if (wktString) {
                        drawWktObj($('#wktInput').val());
                    } else {
                        alert("Please paste a valid WKT string"); // TODO i18n this
                    }
                });

                $('#catalogueSearchQueries').on('input', function() {
                    var value = $('#catalogueSearchQueries').val();

                    $('#catalogueSearchButton').attr('disabled', value.trim().length === 0);
                });
            }); // end $(document).ready()

            // XXX
            // extend tooltip with callback
            // var tmp = $.fn.tooltip.Constructor.prototype.show;
            // $.fn.tooltip.Constructor.prototype.show = function () {
            //     tmp.call(this);
            //     if (this.options.callback) {
            //         this.options.callback();
            //     }
            // };

            var defaultBaseLayer = L.tileLayer("${grailsApplication.config.map.minimal.url}", {
                attribution: "${raw(grailsApplication.config.map.minimal.attr)}",
                subdomains: "${grailsApplication.config.map.minimal.subdomains}",
                mapid: "${grailsApplication.config.map.mapbox?.id?:''}",
                token: "${grailsApplication.config.map.mapbox?.token?:''}"
            });

            // Global var to store map config
            var MAP_VAR = {
                map : null,
                mappingUrl : "${mappingUrl}",
                query : "${searchString}",
                queryDisplayString : "${queryDisplayString}",
                //center: [-30.0,133.6],
                defaultLatitude : "${grailsApplication.config.map.defaultLatitude?:'-25.4'}",
                defaultLongitude : "${grailsApplication.config.map.defaultLongitude?:'133.6'}",
                defaultZoom : "${grailsApplication.config.map.defaultZoom?:'4'}",
                overlays : {
                    <g:if test="${grailsApplication.config.map.overlay.url}">
                        "${grailsApplication.config.map.overlay.name?:'overlay'}" : L.tileLayer.wms("${grailsApplication.config.map.overlay.url}", {
                            layers: 'ALA:ucstodas',
                            format: 'image/png',
                            transparent: true,
                            attribution: "${grailsApplication.config.map.overlay.name?:'overlay'}"
                        })
                    </g:if>
                },
                baseLayers : {
                    "Minimal" : defaultBaseLayer,
                    //"Night view" : L.tileLayer(cmUrl, {styleId: 999,   attribution: cmAttr}),
                    "Road" :  new L.Google('ROADMAP'),
                    "Terrain" : new L.Google('TERRAIN'),
                    "Satellite" : new L.Google('HYBRID')
                },
                layerControl : null,
                //currentLayers : [],
                //additionalFqs : '',
                //zoomOutsideScopedRegion: ${(grailsApplication.config.map.zoomOutsideScopedRegion == false || grailsApplication.config.map.zoomOutsideScopedRegion == "false") ? false : true}
            };

            function initialiseMap() {
                //alert('starting map');
                if(MAP_VAR.map != null){
                    return;
                }

                //initialise map
                MAP_VAR.map = L.map('leafletMap', {
                    center: [MAP_VAR.defaultLatitude, MAP_VAR.defaultLongitude],
                    zoom: MAP_VAR.defaultZoom,
                    minZoom: 1,
                    scrollWheelZoom: false
    //                fullscreenControl: true,
    //                fullscreenControlOptions: {
    //                    position: 'topleft'
    //                }
                });

                //add edit drawing toolbar
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
                    //setup onclick event for this object
                    var layer = e.layer;
                    //console.log("layer",layer, layer._latlng.lat);
                    generatePopup(layer, layer._latlng, MAP_VAR.query, MAP_VAR.map);
                    addClickEventForVector(layer, MAP_VAR.query, MAP_VAR.map);
                    MAP_VAR.drawnItems.addLayer(layer);
                });

                MAP_VAR.map.on('draw:edited', function(e) {
                    //setup onclick event for this object
                    var layers = e.layers;
                    layers.eachLayer(function (layer) {
                        generatePopup(layer, layer._latlng, MAP_VAR.query, MAP_VAR.map);
                        addClickEventForVector(layer, MAP_VAR.query, MAP_VAR.map);
                    });
                });

                //add the default base layer
                MAP_VAR.map.addLayer(defaultBaseLayer);

                L.control.coordinates({position:"bottomright", useLatLngOrder: true}).addTo(MAP_VAR.map); // coordinate plugin

                MAP_VAR.layerControl = L.control.layers(MAP_VAR.baseLayers, MAP_VAR.overlays, {collapsed:true, position:'topleft'});
                MAP_VAR.layerControl.addTo(MAP_VAR.map);

                L.Util.requestAnimFrame(MAP_VAR.map.invalidateSize, MAP_VAR.map, !1, MAP_VAR.map._container);
                L.Browser.any3d = false; // FF bug prevents selects working properly

                // Add a help tooltip to map when first loaded
                // MAP_VAR.map.whenReady(function() {
                //     var opts = {
                //         placement:'right',
                //         callback: destroyHelpTooltip // hide help tooltip when mouse over the tools
                //     }
                //     $('.leaflet-draw-toolbar a').tooltip(opts);
                //     $('.leaflet-draw-toolbar').first().attr('title',jQuery.i18n.prop('advancedsearch.js.choosetool')).tooltip({placement:'right'}).tooltip('show');
                // });

                // // Hide help tooltip on first click event
                // var once = true;
                // MAP_VAR.map.on('click', function(e) {
                //     if (once) {
                //         $('.leaflet-draw-toolbar').tooltip('destroy');
                //         once = false;
                //     }
                // });
            }

            // var once = true;
            // function destroyHelpTooltip() {
            //     if ($('.leaflet-draw-toolbar').length && once) {
            //         $('.leaflet-draw-toolbar').tooltip('destroy');
            //         once = false;
            //     }
            // }
        </r:script>
    </head>

    <body>
        <g:if test="${flash.message}">
            <div class="message alert alert-info">
                <button type="button" class="close" onclick="$(this).parent().hide()">
                    ×
                </button>
                <b>
                    <g:message code="home.index.body.alert" />
                </b>
                ${raw(flash.message)}
            </div>
        </g:if>


        <div class="page-header">
            <h1 class="page-header__title">
                <g:message code="home.index.title" />
            </h1>

            <div class="page-header__subtitle">
                <%-- TODO --%>
                <g:message code="home.index.subtitle" args="${[raw(hubDisplayName)]}" />
            </div>
        </div>

        <div class="tabbable">
            <ul class="nav nav-tabs" id="searchTabs">
                <li class="nav-item">
                    <a id="t1" href="#simple-search" data-toggle="tab" class="nav-link active">
                        <g:message code="home.index.navigator01" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t2" href="#advanced-search" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator02" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t3" href="#taxa-upload" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator03" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t4" href="#catalog-upload" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator04" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t5" href="#spatial-search" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator05" />
                    </a>
                </li>
            </ul>
        </div>

        <div class="tab-content searchPage">
            <div id="simple-search" class="tab-pane active">
                <div class="row">
                    <div class="col-xs-12 col-lg-6">
                        <form name="simpleSearchForm" id="simpleSearchForm" action="${request.contextPath}/occurrences/search" method="GET">
                            <div class="input-plus">
                                <input type="text" name="taxa" id="taxa" class="input-plus__field" />

                                <button id="locationSearch" type="submit" class="erk-button erk-button--dark input-plus__addon">
                                    <g:message code="advancedsearch.button.submit" />
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="row">
                    <div class="col">
                        <small>
                            <g:message code="home.index.simsplesearch.help" />
                        </small>
                    </div>
                </div>
            </div>

            <div id="advanced-search" class="tab-pane">
                <g:render template="advanced" />
            </div> <%-- end #advancedSearch div --%>

            <div id="taxa-upload" class="tab-pane">
                <form name="taxaUploadForm" id="taxaUploadForm" action="${biocacheServiceUrl}/occurrences/batchSearch" method="POST">
                    <p>
                        <g:message code="home.index.taxaupload.des01" />
                    </p>
                    <%-- <p><input type="hidden" name="MAX_FILE_SIZE" value="2048" /><input type="file" /></p> --%>
                    <p>
                        <textarea name="queries" id="raw_names" class="col-6" rows="15" cols="60"></textarea>
                    </p>
                    <div>
                        <%-- <input type="submit" name="action" value="Download" /> --%>
                        <%-- &nbsp;OR&nbsp; --%>
                        <input type="hidden" name="redirectBase" value="${serverName}${request.contextPath}/occurrences/search" />
                        <input type="hidden" name="field" value="raw_name" />
                        <input type="submit" name="action" value=<g:message code="advancedsearch.button.submit" /> class="erk-button erk-button--light" />
                    </div>
                </form>
            </div> <!-- end #uploadDiv div -->

            <div id="catalog-upload" class="tab-pane">
                <form name="catalogUploadForm" id="catalogUploadForm" action="${biocacheServiceUrl}/occurrences/batchSearch" method="POST">
                    <p>
                        <g:message code="home.index.catalogupload.des01" />
                    </p>

                    <%-- <p><input type="hidden" name="MAX_FILE_SIZE" value="2048" /><input type="file" /></p> --%>

                    <p>
                        <textarea id="catalogueSearchQueries" name="queries" id="catalogue_numbers" class="col-6" rows="15" cols="60"></textarea>
                    </p>

                    <div>
                        <%-- <input type="submit" name="action" value="Download" /> --%>
                        <%-- &nbsp;OR&nbsp; --%>
                        <input type="hidden" name="redirectBase" value="${serverName}${request.contextPath}/occurrences/search" />
                        <input type="hidden" name="field" value="catalogue_number" />
                        <%-- XXX --%>
                        <input id="catalogueSearchButton" disabled type="submit" name="action" value=<g:message code="advancedsearch.button.submit" />  class="erk-button erk-button--light" />
                    </div>
                </form>
            </div><%-- end #catalogUploadDiv div --%>

            <div id="spatial-search" class="tab-pane">
                <div class="row">
                    <div class="col-3">
                        <p>
                            <g:message code="search.map.helpText" />
                        </p>

                        <div class="accordion accordion-caret" id="accordion2">
                            <div class="accordion-group">
                                <div class="accordion-heading">
                                    <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapseOne">
                                        <g:message code="search.map.importToggle" />
                                    </a>
                                </div>

                                <div id="collapseOne" class="accordion-body collapse show">
                                    <div class="accordion-inner">
                                        <p>
                                            <g:message code="search.map.importText" />
                                        </p>

                                        <p>
                                            <textarea type="text" id="wktInput"></textarea>
                                        </p>

                                        <button class="erk-button erk-button--light" id="addWkt">
                                            <g:message code="search.map.wktButtonText" />
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-9">
                        <div id="leafletMap" style="height:600px;"></div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
