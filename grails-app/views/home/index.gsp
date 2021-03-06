<%@ page import="org.springframework.web.servlet.support.RequestContextUtils" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<g:set var="hubDisplayName" value="${grailsApplication.config.skin.orgNameLong}" />
<g:set var="biocacheServiceUrl" value="${grailsApplication.config.biocacheService.ui.url}" />
<g:set var="serverName" value="${grailsApplication.config.serverRoot}" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="search" />

        <title>
            <g:message code="home.index.title" />
        </title>

        <asset:stylesheet src="index.css" />
        <asset:javascript src="index.js" />

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
                        <g:message code="general.spatialSearch" />
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

        <asset:deferredScripts />

        <g:javascript>
            function validateBatchForm(inputID) {
                var inputText = $('#' + inputID).val().trim();
                $('#' + inputID).val(inputText);
                return inputText.length !== 0;
            }

            // Global var to store map config
            var MAP_VAR = {
                map: null,
                mappingUrl: "${mappingUrl}",
                query: "${searchString}",
                queryDisplayString: "${queryDisplayString}",
                defaultLatitude: "${grailsApplication.config.map.defaultLatitude}",
                defaultLongitude: "${grailsApplication.config.map.defaultLongitude}",
                defaultZoom: 7,
                layerControl : null,
            };
        </g:javascript>
    </body>
</html>
