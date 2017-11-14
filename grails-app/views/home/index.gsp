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
            <g:message code="home.index.title" />
        </title>

        <asset:stylesheet src="index.css" />
        <asset:javascript src="index.js" />

        <script src="https://maps.google.com/maps/api/js?v=3.5&sensor=false"></script>
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
                    <a id="t1" href="#tab-simple-search" data-toggle="tab" class="nav-link active">
                        <g:message code="home.index.navigator01" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t2" href="#tab-advanced-search" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator02" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t3" href="#tab-taxa-upload" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator03" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t4" href="#tab-catalog-upload" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator04" />
                    </a>
                </li>
                <li class="nav-item">
                    <a id="t5" href="#tab-spatial-search" data-toggle="tab" class="nav-link">
                        <g:message code="home.index.navigator05" />
                    </a>
                </li>
            </ul>
        </div>

        <%-- Simple Search --%>
        <div class="tab-content searchPage">
            <div id="tab-simple-search" class="tab-pane active">
                <div class="row">
                    <div class="col-xs-12 col-lg-6">
                        <p>
                            <span class="fa fa-info-circle"></span>
                            <g:message code="home.index.simsplesearch.help" />
                        </p>
                        <form
                            id="simpleSearchForm"
                            name="simpleSearchForm"
                            action="${request.contextPath}/occurrences/search"
                            method="GET"
                        >
                            <div class="input-plus">
                                <input type="text" name="taxa" id="taxa" class="input-plus__field" />

                                <button
                                    type="submit"
                                    id="locationSearch"
                                    class="erk-button erk-button--dark input-plus__addon"
                                >
                                    <span class="fa fa-search"></span>
                                    <g:message code="advancedsearch.button.submit" />
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>

            <%-- Adv Search --%>
            <div id="tab-advanced-search" class="tab-pane">
                <g:render template="advanced" />
            </div>

            <%-- Batch Taxa Search --%>
            <div id="tab-taxa-upload" class="tab-pane">
                <form
                    id="taxaUploadForm"
                    name="taxaUploadForm"
                    action="${biocacheServiceUrl}/occurrences/batchSearch"
                    method="POST"
                    onsubmit="return validateBatchForm('batch-taxon-input');"
                >
                    <p>
                        <span class="fa fa-info-circle"></span>
                        <g:message code="home.index.taxaupload.des01" />
                    </p>

                    <p>
                        <textarea
                            id="batch-taxon-input"
                            name="queries"
                            class="col-12 col-md-10 col-lg-8 col-xl-6"
                            rows="15"
                            cols="60"
                            required
                        ></textarea>
                    </p>

                    <div>
                        <input
                            type="hidden"
                            name="redirectBase"
                            value="${serverName}${request.contextPath}/occurrences/search"
                        />
                        <input type="hidden" name="field" value="raw_name" />

                        <input type="hidden" name="action" value="Search" />

                        <button
                            type="submit"
                            class="erk-button erk-button--dark"
                        >
                            <span class="fa fa-search"></span>
                            <g:message code="advancedsearch.button.submit" />
                        </button>
                    </div>
                </form>
            </div>

            <%-- Catalogue Number Search --%>
            <div id="tab-catalog-upload" class="tab-pane">
                <form
                    id="catalogUploadForm"
                    name="catalogUploadForm"
                    action="${biocacheServiceUrl}/occurrences/batchSearch"
                    method="POST"
                    onsubmit="return validateBatchForm('catalogue-numbers-input');"
                >
                    <p>
                        <span class="fa fa-info-circle"></span>
                        <g:message code="home.index.catalogupload.des01" />
                    </p>

                    <p>
                        <textarea
                            id="catalogue-numbers-input"
                            name="queries"
                            class="col-12 col-md-10 col-lg-8 col-xl-6"
                            rows="15"
                            cols="60"
                            required
                        ></textarea>
                    </p>

                    <div>
                        <input
                            type="hidden"
                            name="redirectBase"
                            value="${serverName}${request.contextPath}/occurrences/search"
                        />
                        <input type="hidden" name="field" value="catalogue_number" />

                        <input type="hidden" name="action" value="Search" />

                        <button
                            type="submit"
                            id="catalogueSearchButton"
                            class="erk-button erk-button--dark"
                        >
                            <span class="fa fa-search"></span>
                            <g:message code="advancedsearch.button.submit" />
                        </button>
                    </div>
                </form>
            </div>

            <%-- Map Search --%>
            <div id="tab-spatial-search" class="tab-pane">
                <div class="row">
                    <div class="col-md-3 wkt-section">
                        <p>
                            <span class="fa fa-info-circle"></span>
                            <g:message code="search.map.helpText" />
                        </p>

                        <div id="wktPanel" class="wkt-panel wkt-section__wkt">
                            <div class="wkt-panel__header">
                                <a
                                    href="#wktBody"
                                    class="wkt-panel__toggle collapsed"
                                    data-toggle="collapse"
                                    data-parent="#wktPanel"
                                >
                                    <g:message code="search.map.importToggle" />
                                </a>
                            </div>

                            <div id="wktBody" class="wkt-panel__body collapse">
                                <div class="wkt-panel__content">
                                    <p>
                                        <g:message code="search.map.importText" />
                                    </p>

                                    <textarea
                                        type="text"
                                        id="wktInput"
                                        class="wkt-panel__input"
                                    ></textarea>

                                    <div id=wkt-input-error class="alert alert-danger collapse" role="alert">
                                        <g:message code="search.map.invalidWKT" />
                                    </div>

                                    <button class="erk-button erk-button--light" id="addWkt">
                                        <g:message code="search.map.wktButtonText" />
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-9">
                        <div id="leafletMap" style="height:600px;"></div>
                    </div>
                </div>
            </div>
        </div>

        <asset:deferredScripts/>

        <g:javascript>
            function validateBatchForm(inputID) {
                var inputText = $('#' + inputID).val().trim();
                $('#' + inputID).val(inputText);
                return inputText.length !== 0;
            }

            var defaultBaseLayer = L.tileLayer("${grailsApplication.config.map.minimal.url}", {
                attribution: "${raw(grailsApplication.config.map.minimal.attr)}",
                subdomains: "${grailsApplication.config.map.minimal.subdomains}",
                mapid: "${grailsApplication.config.map.mapbox?.id?:''}",
                token: "${grailsApplication.config.map.mapbox?.token?:''}"
            });

            // Global var to store map config
            var MAP_VAR = {
                map: null,
                mappingUrl: "${mappingUrl}",
                query: "${searchString}",
                queryDisplayString: "${queryDisplayString}",
                defaultLatitude: "${grailsApplication.config.map.defaultLatitude ?: '58.3735'}",
                defaultLongitude: "${grailsApplication.config.map.defaultLongitude ?: '26.7161'}",
                defaultZoom: 7,
                overlays: {
                    <g:if test="${grailsApplication.config.map.overlay.url}">
                        "${grailsApplication.config.map.overlay.name?:'overlay'}" : L.tileLayer.wms("${grailsApplication.config.map.overlay.url}", {
                            layers: 'ALA:ucstodas',
                            format: 'image/png',
                            transparent: true,
                            attribution: "${grailsApplication.config.map.overlay.name?:'overlay'}"
                        })
                    </g:if>
                },
                baseLayers: {
                    "Minimal": defaultBaseLayer,
                    //"Night view" : L.tileLayer(cmUrl, {styleId: 999,   attribution: cmAttr}),
                    "Road":  new L.Google('ROADMAP'),
                    "Terrain": new L.Google('TERRAIN'),
                    "Satellite": new L.Google('HYBRID')
                },
                layerControl : null,
            };
        </g:javascript>
    </body>
</html>
