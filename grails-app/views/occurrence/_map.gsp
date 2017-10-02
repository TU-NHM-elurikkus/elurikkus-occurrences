<%@ page contentType="text/html;charset=UTF-8" %>

<div style="margin-bottom: 10px">
    <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
        <g:set var='spatialPortalLink' value="${sr.urlParameters}" />
        <g:set var='spatialPortalUrlParams' value="${grailsApplication.config.spatial.params}" />

        <div id="spatialPortalBtn" class="erk-button erk-button--light" style="margin-bottom: 2px;">
            <a id="spatialPortalLink"
                class="tooltips"
                href="${grailsApplication.config.spatial.baseUrl}${spatialPortalLink}${spatialPortalUrlParams}"
                title="Continue analysis in ALA Spatial Portal"
            >
                <span class="fa fa-map-marker"></span>&nbsp;&nbsp;
                <g:message code="map.spatialportal.btn.label" />
            </a>
        </div>
    </g:if>

    <button id="downloadMaps" data-toggle="modal" data-target="#downloadMap" class="erk-button erk-button--light" style="margin-bottom: 2px;">
        <span class="fa fa-download"></span>
        <g:message code="search.map.download.label" />
    </button>

    <g:if test="${params.wkt}">
        <button id="downloadWKT" class="erk-button erk-button--light" style="margin-bottom: 2px;" class="tooltip" onclick="downloadPolygon(); return false;">
            <span class="fa fa-download"></span>
            <g:message code="map.downloadwkt.btn.label" />
        </button>
    </g:if>

    <%--
    <div id="spatialSearchFromMap" class="erk-button erk-button--light">
        <button id="wktFromMapBounds" class="tooltips" title="Restrict search to current view">
            <i class="hide icon-share-alt"></i>
            Restrict search
        </button>
    </div>

    TODO - Needs hook in UI to detect a wkt param and include button/link under search query and selected facets.
    TODO - Also needs to check if wkt is already specified and remove previous wkt param from query.
    --%>
</div>

<div class="hide" id="recordLayerControls">
    <table id="mapLayerControls">
        <tr>
            <td>
                <label for="colourBySelect">
                    <g:message code="map.maplayercontrols.tr01td01.label" />:&nbsp;
                </label>

                <div class="layerControls">
                    <select name="colourBySelect" id="colourBySelect" onchange="occMap.changeFacetColours();return true;">
                        <option value="">
                            <g:message code="map.maplayercontrols.tr01td01.option01" />
                        </option>

                        <option value="grid" ${(defaultColourBy == 'grid')?'selected=\"selected\"':''}>
                            <g:message code="map.maplayercontrols.tr01td01.option02" />
                        </option>

                        <option value="gridVariable" ${(defaultColourBy == 'gridVariable')?'selected=\"selected\"':''}>
                            <g:message code="map.maplayercontrols.tr01td01.option03" />
                        </option>

                        <option value="taimeatlasGrid" ${(defaultColourBy == 'taimeatlasGrid')? 'selected=\"selected\"' : ''}>
                            <g:message code="map.maplayercontrols.mode.taimeatlas" />
                        </option>

                        <option disabled role="separator">————————————</option>

                        <g:set var="excludedFacets">
                            ${grailsApplication.config.facets.mapExclude?:""}.split(",")
                        </g:set>
                        <g:each var="facetResult" in="${facets}">
                            <g:if test="${!excludedFacets.contains(facetResult.fieldName)}">
                                <g:set var="defaultselected">
                                    <g:if test="${defaultColourBy && facetResult.fieldName == defaultColourBy}">
                                        selected="selected"
                                    </g:if>
                                </g:set>

                                <g:if test="${facetResult.fieldResult.size() > 1 || defaultselected}">
                                    <option value="${facetResult.fieldName}" ${defaultselected}>
                                        <alatag:formatDynamicFacetName fieldName="${facetResult.fieldName}" />
                                    </option>
                                </g:if>
                            </g:if>
                        </g:each>
                    </select>

                    <select id="ta-grid-color-mode" class="hidden-node">
                        <option value="linear">
                            <g:message code="map.controls.ta_grid_color_mode.linear" />
                        </option>

                        <option value="logscale">
                            <g:message code="map.controls.ta_grid_color_mode.logscale" />
                        </option>

                        <option value="quantile">
                            <g:message code="map.controls.ta_grid_color_mode.quantile" />
                        </option>
                    </select>
                </div>
            </td>

            <td>
                <label for="sizeslider">
                    <g:message code="map.maplayercontrols.tr01td02.label" />:
                </label>

                <div class="layerControls">
                    <span class="slider-val" id="sizeslider-val">2</span>
                </div>

                <div id="sizeslider" style="width:75px;"></div>
            </td>

            <td>
                <label for="opacityslider">
                    <g:message code="map.maplayercontrols.tr01td03.label" />:
                </label>

                <div class="layerControls">
                    <span class="slider-val" id="opacityslider-val">0.9</span>
                </div>

                <div id="opacityslider" style="width:75px;"></div>
            </td>

            <td>
                <label for="outlineDots">
                    <g:message code="map.maplayercontrols.tr01td04.label" />:
                </label>

                <input type="checkbox" name="outlineDots" value="false" class="layerControls" id="outlineDots">
            </td>
        </tr>
    </table>
</div>

<div id="leafletMap" class="span12" style="height:600px;"></div>

<div id="template" style="display:none">
    <div class="colourbyTemplate">
        <a class="colour-by-legend-toggle colour-by-control tooltips" href="#" title="${message(code: 'map.legend.title')}">
            <span class="fa fa-list-ul fa-lg"></span>
        </a>

        <form class="leaflet-control-layers-list">
            <div class="leaflet-control-layers-overlays">
                <div style="overflow:auto; max-height:400px;">
                    <a href="#" class="hideColourControl pull-right" style="padding-left:10px;">
                        <span class="fa fa-remove"></span>
                    </a>

                    <div class="legend-container">
                        <table class="legendTable"></table>

                        <button id="legendLoadMore" class="erk-link-button hidden-node">
                            <g:message code="general.btn.loadMore" />
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<div id="recordPopup" style="display:none;">
    <a href="#">
        <g:message code="map.recordpopup" />
    </a>
</div>


<script>
    var defaultBaseLayer = L.tileLayer("${grailsApplication.config.map.minimal.url}", {
        attribution: "${raw(grailsApplication.config.map.minimal.attr)}",
        subdomains: "${grailsApplication.config.map.minimal.subdomains}",
        mapid: "${grailsApplication.config.map.mapbox?.id?:''}",
        token: "${grailsApplication.config.map.mapbox?.token?:''}"
    });

    var translations = {
        'record.catalogNumber.label': "${g.message(code: 'record.catalogNumber.label')}",
        'record.fieldNumber.label': "${g.message(code: 'record.fieldNumber.label')}",
        'record.recordNumber.label': "${g.message(code: 'record.recordNumber.label')}",
        'record.institutionName.label': "${g.message(code: 'record.institutionName.label')}",
        'record.dataResourceName.label': "${g.message(code: 'record.dataResourceName.label')}",
        'record.collectionName.label': "${g.message(code: 'record.collectionName.label')}",
        'record.recordedBy.label': "${g.message(code: 'record.recordedBy.label')}",
        'record.eventDate.label': "${g.message(code: 'record.eventDate.label')}",
        'search.recordNotFoundForId': "${g.message(code: 'search.recordNotFoundForId')}"
    };

    var occMap = new OccurrenceMap("${searchString}", {
        mappingUrl : "${mappingUrl}",
        queryDisplayString : "${queryDisplayString}",
        center: [
            "${grailsApplication.config.map.defaultLatitude?:'58.67'}",
            "${grailsApplication.config.map.defaultLongitude?:'25.56'}",
        ],
        defaultZoom : "${grailsApplication.config.map.defaultZoom?:'4'}",
        overlays : {
            <g:if test="${grailsApplication.config.map.overlay.url}">
                //example WMS layer
                "${grailsApplication.config.map.overlay.name?:'overlay'}" : L.tileLayer.wms("${grailsApplication.config.map.overlay.url}", {
                    layers: 'ALA:ucstodas',
                    format: 'image/png',
                    transparent: true,
                    attribution: "${grailsApplication.config.map.overlay.name?:'overlay'}"
                })
            </g:if>
        },
        baseLayer: defaultBaseLayer,
        zoomOutsideScopedRegion: ${(grailsApplication.config.map.zoomOutsideScopedRegion == false || grailsApplication.config.map.zoomOutsideScopedRegion == "false") ? false : true},
        pointColour: "${grailsApplication.config.map.pointColour}",
        contextPath: "${request.contextPath}",
        translations: translations,
        biocacheServiceURL: '${alatag.getBiocacheAjaxUrl()}',
        wkt: "${params.wkt}"
    });

    function initialiseMap(){
        occMap.initialize();
    }

    /**
     * http://stackoverflow.com/questions/3916191/download-data-url-file
     */
    function downloadPolygon() {
      var uri = "data:text/html,${params.wkt}",
          name = "polygon.txt";
      var link = document.createElement("a");
      link.download = name;
      link.href = uri;
      document.body.appendChild(link);
      link.click();
      // Cleanup the DOM
      document.body.removeChild(link);
      delete link;
      return false;
    }
</script>

<div style="display: none;">
    <div class="popupRecordTemplate">
        <div class="multiRecordHeader hide">
            <g:message code="search.map.viewing" />
            <span class="currentRecord"></span>
            <g:message code="search.map.of" />
            <span class="totalrecords"></span>
            <g:message code="search.map.occurrences" />
        </div>

        <a href="#" class="erk-link viewAllRecords">
            <span class="fa fa-list"></span>
            <g:message code="search.map.viewAllRecords" />
        </a>

        <div class="recordSummary"></div>

        <div class="hide multiRecordFooter">
            <button class="erk-link-button disabled previousRecord">
                <g:message code="search.map.popup.prev" />
            </button>

            <a href="#" class="erk-link recordLink">
                <g:message code="search.map.popup.viewRecord" />
            </a>

            <button type="button" class="erk-link-button disabled nextRecord">
                <g:message code="search.map.popup.next" />
            </button>
        </div>
    </div>
</div>

<div id="downloadMap" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="downloadMapForm">
                <div class="modal-header">
                    <h3 id="downloadsMapLabel">
                        <g:message code="map.downloadmap.title" />
                    </h3>
                </div>

                <div class="modal-body">
                    <input id="mapDownloadUrl" type="hidden" value="${alatag.getBiocacheAjaxUrl()}/webportal/wms/image" />

                    <fieldset>
                        <p>
                            <label for="format">
                                <g:message code="map.downloadmap.field01.label" />
                            </label>

                            <select name="format" id="format">
                                <option value="jpg">
                                    <g:message code="map.downloadmap.field01.option01" />
                                </option>

                                <option value="png">
                                    <g:message code="map.downloadmap.field01.option02" />
                                </option>
                            </select>
                        </p>

                        <p>
                            <label for="dpi">
                                <g:message code="map.downloadmap.field02.label" />
                            </label>

                            <select name="dpi" id="dpi">
                                <option value="100">100</option>
                                <option value="300" selected="true">300</option>
                                <option value="600">600</option>
                            </select>
                        </p>

                        <p>
                            <label for="pradiusmm">
                                <g:message code="map.downloadmap.field03.label" />
                            </label>

                            <select name="pradiusmm" id="pradiusmm">
                                <option>0.1</option>
                                <option selected>0.2</option>
                                <option>0.3</option>
                                <option>0.4</option>
                                <option>0.5</option>
                                <option>0.6</option>
                                <option >0.7</option>
                                <option>0.8</option>
                                <option>0.9</option>
                                <option>1</option>
                                <option>2</option>
                                <option>3</option>
                                <option>4</option>
                                <option>5</option>
                                <option>6</option>
                                <option>7</option>
                                <option>8</option>
                                <option>9</option>
                                <option>10</option>
                            </select>
                        </p>

                        <p>
                            <label for="popacity">
                                <g:message code="map.maplayercontrols.tr01td03.label" />
                            </label>

                            <select name="popacity" id="popacity">
                                <option>1</option>
                                <option selected>0.9</option>
                                <option>0.8</option>
                                <option>0.7</option>
                                <option>0.6</option>
                                <option>0.5</option>
                                <option>0.4</option>
                                <option>0.3</option>
                                <option>0.2</option>
                                <option>0.1</option>
                            </select>
                        </p>

                        <p id="colourPickerWrapper">
                            <label for="pcolour">
                                <g:message code="map.downloadmap.field05.label" />
                            </label>

                            <input type="color" name="pcolour" id="pcolour" value="#0D00FB">
                        </p>

                        <p>
                            <label for="widthmm">
                                <g:message code="map.downloadmap.field06.label" />
                            </label>

                            <input type="text" name="widthmm" id="widthmm" value="150" />
                        </p>

                        <p>
                            <label for="scale_on">
                                <g:message code="map.downloadmap.field07.label" />
                            </label>

                            <input type="radio" name="scale" value="on" id="scale_on" checked="checked" />
                            <g:message code="general.bool.true" /> &nbsp;

                            <input type="radio" name="scale" value="off" />
                            <g:message code="general.bool.false" />
                        </p>

                        <p>
                            <label for="outline">
                                <g:message code="map.downloadmap.field08.label" />
                            </label>

                            <input type="radio" name="outline" value="true" id="outline" checked="checked" />
                            <g:message code="general.bool.true" /> &nbsp;

                            <input type="radio" name="outline" value="false" />
                            <g:message code="general.bool.false" />
                        </p>

                        <p>
                            <label for="baselayer">
                                <g:message code="map.downloadmap.layer.label" />
                            </label>
                            <select name="baselayer" id="baselayer">
                                <option value="world" selected>
                                    <g:message code="map.downloadmap.layer.world" />
                                </option>

                                <option value="maakonnad_intersected_for_real">
                                    <g:message code="map.downloadmap.layer.counties" />
                                </option>

                                <option value="omavalitsused">
                                    <g:message code="map.downloadmap.layer.localGovernment" />
                                </option>
                            </select>
                        </p>

                        <p>
                            <label for="fileName">
                                <g:message code="map.downloadmap.fileName.label" />
                            </label>

                            <input
                                id="fileName"
                                type="text"
                                name="fileName"
                                value="${message(code: 'map.downloadmap.fileName.value')}"
                            />
                        </p>
                    </fieldset>
                </div>

                <div class="modal-footer">
                    <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                        <g:message code="general.btn.close" />
                    </button>

                    <button id="submitDownloadMap" class="erk-button erk-button--light">
                        <span class="fa fa-download"></span>
                        <g:message code="general.btn.download.label" />
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        // restrict search to current map bounds/view
        $('#wktFromMapBounds').click(function(e) {
            var b = occMap.map.getBounds();
            var wkt = "POLYGON ((" + b.getWest() + " " + b.getNorth() + ", " +
                    b.getEast()  + " " + b.getNorth() + ", " +
                    b.getEast()  + " " + b.getSouth() + ", " +
                    b.getWest()  + " " + b.getSouth() + ", " +
                    b.getWest() + " " + b.getNorth() + "))";
            var url = "${g.createLink(uri:'/occurrences/search')}" + occMap.query + "&wkt=" + encodeURIComponent(wkt);
            window.location.href = url;
        });
    });
</script>
