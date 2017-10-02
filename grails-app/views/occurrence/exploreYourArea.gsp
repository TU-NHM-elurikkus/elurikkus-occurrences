<%@ page contentType="text/html;charset=UTF-8" %>

<g:set var="biocacheServiceUrl" value="${grailsApplication.config.biocache.baseUrl}" />
<g:set var="queryContext" value="${grailsApplication.config.biocache.queryContext}" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="yourArea" />
        <title>
            <g:message code="eya.title" />
        </title>

        <g:if test="${grailsApplication.config.google.apikey}">
            <script src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>
        </g:if>
        <g:else>
            <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        </g:else>

        <asset:javascript src="eya.js" />
        <asset:stylesheet src="exploreYourArea.css" />
    </head>

    <body class="nav-locations explore-your-area">
        <div class="page-header">
            <h1 class="page-header__title">
                <g:message code="eya.title" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="eya.description" />
            </div>

            <div class="page-header-links">
                <a class="page-header-links__link" href="http://ala-test.ut.ee/regions/#rt=Maakonnad">
                    <span class="fa fa-search"></span>
                    <g:message code="menu.regions.label" />
                </a>
                <a class="page-header-links__link" href="${request.contextPath}/search?#spatial-search">
                    <span class="fa fa-search"></span>
                    <g:message code="general.searchByPolygon" />
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <%-- SEARCH INPUT --%>
                <div class="search-section">
                    <form name="searchForm" id="searchForm" action="" method="GET">
                        <div
                            class="input-plus"
                            title="${message(code: 'eya.btn.search.tooltip')}"
                            data-toggle="tooltip"
                        >
                            <input
                                type="text"
                                name="address"
                                id="address"
                                placeholder="${message(code: 'eya.btn.search.placeholder')}"
                                class="input-plus__field"
                            />

                            <button
                                type="submit"
                                id="locationSearch"
                                class="erk-button erk-button--dark input-plus__addon"
                            >
                                <span class="fa fa-search"></span>
                                <g:message code="advancedsearch.button.submit" />
                            </button>
                        </div>

                        <input type="hidden" name="latitude" id="latitude" value="${latitude}" />
                        <input type="hidden" name="longitude" id="longitude" value="${longitude}" />
                        <input type="hidden" name="location" id="location" value="${location}" />
                    </form>

                    <g:if test="${location}">
                        <p>
                            <g:message code="eya.searchform.label02" />:

                            <span id="markerAddress">
                                ${location}
                            </span>
                        </p>
                    </g:if>

                    <%-- TODO XXX --%>
                    <div id="dialog-confirm" title="<g:message code='eya.dialogconfirm.title' />" style="display: none">
                        <p>
                            <%-- TODO XXX --%>
                            <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
                            <g:message code="eya.dialogconfirm01" />
                            <span id="rad"></span>
                            <g:message code="eya.dialogconfirm02" />
                            <code>
                                ${location}
                            </code>.
                            <br />
                            <g:message code="eya.dialogconfirm03" />
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <%-- TAXA INFO --%>
            <div class="col-sm-12 col-md-6 col-lg-5">
                <div class="column-reverse">
                    <p>
                        <span class="fa fa-info-circle"></span>
                        <g:message code="eya.groupTable.help" />
                    </p>
                </div>
            </div>

            <%-- TAXA CONTROLS --%>
            <div class="col-sm-12 col-md-6 col-lg-5 order-md-3">
                <div id="taxaBox">
                    <div id="leftList">
                        <table id="taxa-level-0">
                            <thead>
                                <tr>
                                    <th>
                                        <g:message code="eya.groupTable.header.group.label" />
                                    </th>
                                    <th>
                                        #
                                    </th>
                                </tr>
                            </thead>

                            <tbody></tbody>
                        </table>
                    </div>

                    <div id="rightList">
                        <div id="rightListHeader">
                            <button
                                class="erk-link-button"
                                data-sort="taxa"
                                data-toggle="tooltip"
                                title="${message(code: 'eya.speciesTable.header.taxon.title')}"
                            >
                                <g:message code="eya.speciesTable.header.taxon.label" />
                            </button>

                            <span>:</span>

                            <button
                                class="erk-link-button"
                                data-sort="common"
                                data-toggle="tooltip"
                                title="${message(code: 'eya.speciesTable.header.common.title')}"
                            >
                                <g:message code="eya.speciesTable.header.common.label" />
                            </button>

                            <button
                                id="right-count"
                                class="erk-link-button"
                                data-sort="count"
                                data-toggle="tooltip"
                                title="${message(code: 'eya.speciesTable.header.count.title')}"
                            >
                                <g:message code="eya.speciesTable.header.count.label" />
                            </button>
                        </div>

                        <div class="tableContainer">
                            <table>
                                <tbody class="scrollContent"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <%-- MAP CONTROLS & INFO --%>
            <div class="col-sm-12 col-md-6 col-lg-7 order-md-2">
                <div class="row">
                    <div class="col-md-12 col-lg-9 col-xl-8 order-lg-2">
                        <div class="inline-controls inline-controls--right">
                            <div class="inline-controls__group">
                                <label for="radius">
                                    <g:message code="eya.searchformradius.label" />
                                </label>
                                <g:select id="radius" name="radius" value="${1}" from="${[1, 5, 10]}" />
                            </div>

                            <div class="inline-controls__group">
                                <button id="viewAllRecords" class="erk-button erk-button--dark">
                                    <span class="fa fa-list"></span>
                                    <g:message code="eya.searchform.viewAllRecords.label" />
                                </button>
                            </div>

                            <div class="inline-controls__group">
                                <button data-toggle="modal" data-target="#download" class="erk-button erk-button--light">
                                    <span class="fa fa-download"></span>
                                    <g:message code="general.btn.download.label" />
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-12 col-lg-3 col-xl-4">
                        <div class="column-reverse">
                            <p>
                                <span class="fa fa-info-circle"></span>
                                <g:message code="eya.maptips" />
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <%-- MAP --%>
            <div class="col-sm-12 col-md-6 col-lg-7 order-md-3">
                <div id="mapCanvas" style="width: 100%; height: 490px;"></div>

                <table id="cellCountsLegend">
                    <tr>
                        <td style="background-color:#000; color:white; text-align:right;">
                            <g:message code="eya.speciesTable.header.count.label" />:&nbsp;
                        </td>

                        <td style="background-color:#ffff00;">
                            1&ndash;9
                        </td>
                        <td style="background-color:#ffcc00;">
                            10&ndash;49
                        </td>
                        <td style="background-color:#ff9900;">
                            50&ndash;99
                        </td>
                        <td style="background-color:#ff6600;">
                            100&ndash;249
                        </td>
                        <td style="background-color:#ff3300;">
                            250&ndash;499
                        </td>
                        <td style="background-color:#cc0000;">
                            500+
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <g:render template="/occurrence/download" />

        <script type="text/javascript">
            // Global variables for yourAreaMap.js
            var EYA_CONF = {
                contextPath: "${request.contextPath}",
                biocacheServiceUrl: "${biocacheServiceUrl.encodeAsHTML()?:''}",
                imagesUrlPrefix: "${request.contextPath}/assets/eya-images",
                zoom: ${zoom ?: 12},
                radius: ${radius},
                speciesPageUrl: "${speciesPageUrl}",
                queryContext: "${queryContext}",
                hasGoogleKey: ${grailsApplication.config.google.apikey as Boolean}
            }

            var eyaState = loadExploreArea(EYA_CONF);

            //make the taxa and rank global variable so that they can be used in the download
            var taxa = ["*"], rank = "*";
        </script>
    </body>
</html>
