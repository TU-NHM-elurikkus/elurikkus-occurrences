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

        <asset:javascript src="index.js"/>

        <script src="http://maps.google.com/maps/api/js?v=3.5&sensor=false"></script>

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
                                    <i class="fa fa-search"></i>
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

                    <p>
                        <textarea name="queries" id="raw_names" class="col-6" rows="15" cols="60"></textarea>
                    </p>

                    <div>
                        <input type="hidden" name="redirectBase" value="${serverName}${request.contextPath}/occurrences/search" />
                        <input type="hidden" name="field" value="raw_name" />

                        <input type="hidden" name="action" value="Search" />

                        <button
                            type="submit"
                            class="erk-button erk-button--dark"
                        >
                            <i class="fa fa-search"></i>
                            <g:message code="advancedsearch.button.submit" />
                        </button>
                    </div>
                </form>
            </div> <!-- end #uploadDiv div -->

            <div id="catalog-upload" class="tab-pane">
                <form name="catalogUploadForm" id="catalogUploadForm" action="${biocacheServiceUrl}/occurrences/batchSearch" method="POST">
                    <p>
                        <g:message code="home.index.catalogupload.des01" />
                    </p>

                    <p>
                        <textarea id="catalogueSearchQueries" name="queries" id="catalogue_numbers" class="col-6" rows="15" cols="60"></textarea>
                    </p>

                    <div>
                        <input type="hidden" name="redirectBase" value="${serverName}${request.contextPath}/occurrences/search" />
                        <input type="hidden" name="field" value="catalogue_number" />

                        <input type="hidden" name="action" value="Search" />

                        <button
                            type="submit"
                            id="catalogueSearchButton"
                            disabled
                            class="erk-button erk-button--dark"
                        >
                            <i class="fa fa-search"></i>
                            <g:message code="advancedsearch.button.submit" />
                        </button>
                    </div>
                </form>
            </div><%-- end #catalogUploadDiv div --%>

            <div id="spatial-search" class="tab-pane">
                <div class="row">
                    <div class="col-3 wkt-section">
                        <p>
                            <g:message code="search.map.helpText" />
                        </p>

                        <div id="wktPanel" class="wkt-panel wkt-section__wkt">
                            <div class="wkt-panel__header">
                                <a class="wkt-panel__toggle collapsed" data-toggle="collapse" data-parent="#wktPanel" href="#wktBody">
                                    <g:message code="search.map.importToggle" />
                                </a>
                            </div>

                            <div id="wktBody" class="wkt-panel__body collapse">
                                <div class="wkt-panel__content">
                                    <p>
                                        <g:message code="search.map.importText" />
                                    </p>

                                    <textarea type="text" id="wktInput" class="wkt-panel__input"></textarea>

                                    <button class="erk-button erk-button--light" id="addWkt">
                                        <g:message code="search.map.wktButtonText" />
                                    </button>
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

        <asset:deferredScripts/>

        <g:javascript>
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
        </g:javascript>
    </body>
</html>
