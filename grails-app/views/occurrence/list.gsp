<%@ page contentType="text/html;charset=UTF-8" %>

<g:set var="queryDisplay" value="${sr?.queryTitle ?: searchRequestParams?.displayString ?: ''}" />
<g:set var="searchQuery" value="${grailsApplication.config.skin.useAlaBie ? 'taxa' : 'q'}" />
<g:set var="authService" bean="authService" />

<g:set var="sortField" value="${params.sort ?: 'first_loaded_date'}" />
<g:set var="sortDir" value="${params.dir ?: 'desc'}" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="svn.revision" content="${meta(name: 'svn.revision')}" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="search" />

        <title>
            <g:message code="search.heading.list" />
        </title>

        <g:if test="${grailsApplication.config.google.apikey}">
            <script src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>
        </g:if>

        <script type="text/javascript" src="https://www.google.com/jsapi"></script>

        <asset:stylesheet src="list.css" />
        <asset:javascript src="list.js" />

        <script type="text/javascript">
            // single global var for app conf settings
            <g:set var="fqParamsSingleQ" value="${(params.fq) ? ' AND ' + params.list('fq')?.join(' AND ') : ''}" />

            <g:set var="fqParams" value="${(params.fq) ? "&fq=" + params.list('fq')?.join('&fq=') : ''}" />
            <g:set var="searchString" value="${raw(sr?.urlParameters).encodeAsURL()}" />
            var BC_CONF_FIELDS = {
                contextPath: "${request.contextPath}",
                hostName: "${grailsApplication.config.serverName}",
                serverName: "${grailsApplication.config.serverName}${request.contextPath}",
                searchString: "${searchString}", //  JSTL var can contain double quotes // .encodeAsJavaScript()
                facetQueries: "${fqParams.encodeAsURL()}",
                facetDownloadQuery: "${searchString}${fqParamsSingleQ}",
                queryString: "${queryDisplay.encodeAsJavaScript()}",
                bieWebappUrl: "${grailsApplication.config.bie.baseUrl}",
                bieWebServiceUrl: "${grailsApplication.config.bieService.baseUrl}",
                biocacheServiceUrl: "${alatag.getBiocacheAjaxUrl()}",
                collectoryUrl: "${grailsApplication.config.collectory.baseUrl}",
                alertsUrl: "${grailsApplication.config.alerts.baseUrl}",
                skin: "${grailsApplication.config.skin.layout}",
                defaultListView: "${grailsApplication.config.defaultListView}",
                resourceName: "${grailsApplication.config.skin.orgNameLong}",
                facetLimit: "${grailsApplication.config.facets.limit ?: 50}",
                queryContext: "${grailsApplication.config.biocache.queryContext}",
                selectedDataResource: "${selectedDataResource}",
                autocompleteHints: "${grailsApplication.config.bie?.autocompleteHints?.encodeAsJson() ?: '{}'}",
                zoomOutsideScopedRegion: Boolean("${grailsApplication.config.map.zoomOutsideScopedRegion}"),
                hasMultimedia: ${hasImages ?: 'false'}, // will be either true or false
                locale: "${org.springframework.web.servlet.support.RequestContextUtils.getLocale(request)}",
                imageServiceBaseUrl:"${grailsApplication.config.images.baseUrl}",
                likeUrl: "${createLink(controller: 'imageClient', action: 'likeImage')}",
                dislikeUrl: "${createLink(controller: 'imageClient', action: 'dislikeImage')}",
                userRatingUrl: "${createLink(controller: 'imageClient', action: 'userRating')}",
                disableLikeDislikeButton: "${authService.getUserId() ? false : true}",
                addLikeDislikeButton: "${(grailsApplication.config.addLikeDislikeButton == false) ? false : true}",
                addPreferenceButton: "${authService?.getUserId() ? (authService.getUserForUserId(authService.getUserId())?.roles?.contains('ROLE_ADMIN') ? true : false) : false}",
                savePreferredSpeciesListUrl: "${createLink(controller: 'imageClient', action: 'saveImageToSpeciesList')}",
                getPreferredSpeciesListUrl:  "${grailsApplication.config.speciesList.baseURL}" // "${createLink(controller: 'imageClient', action: 'getPreferredSpeciesImageList')}"
            };

            BC_CONF["sortField"] = "${sortField}";
            BC_CONF["sortDir"] = "${sortDir}";

            for(var field in BC_CONF_FIELDS) {
                if(BC_CONF_FIELDS.hasOwnProperty(field)) {
                    BC_CONF[field] = BC_CONF_FIELDS[field];
                }
            }
        </script>

        <script type="text/javascript">
            <g:if test="${!grailsApplication.config.google.apikey}">
                google.load('maps','3.5',{ other_params: "sensor=false" });
            </g:if>

            google.load("visualization", "1", {packages:["corechart"]});
        </script>
    </head>

    <body class="occurrence-search">
        <div id="listHeader" class="page-header">
            <h1 class="page-header__title">
                <g:message code="search.heading.list" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="home.index.subtitle" args="${['eElurikkus']}" />
            </div>

            <div class="page-header-links">
                <a href="${g.createLink(uri: '/search')}#advanced-search" class="page-header-links__link">
                    <span class="fa fa-search"></span>
                    <g:message code="home.index.navigator02" />
                </a>

                <a href="${g.createLink(uri: '/search')}#taxa-upload" class="page-header-links__link">
                    <span class="fa fa-search"></span>
                    <g:message code="home.index.navigator03" />
                </a>

                <a href="${g.createLink(uri: '/search')}#catalog-upload" class="page-header-links__link">
                    <span class="fa fa-search"></span>
                    <g:message code="home.index.navigator04" />
                </a>

                <a href="${g.createLink(uri: '/search')}#spatial-search" class="page-header-links__link">
                    <span class="fa fa-search"></span>
                    <g:message code="general.spatialSearch" />
                </a>
            </div>

            <%-- THE HELL --%>
            <input type="hidden" id="userId" value="${userId}" />
            <input type="hidden" id="userEmail" value="${userEmail}" />
            <input type="hidden" id="lsid" value="${params.lsid}" />
        </div>

        <%-- Seems like unneeded code --%>
        <g:if test="${flash.message}">
            <div id="errorAlert" class="alert alert-danger alert-dismissible" role="alert">
                <button type="button" class="close" onclick="$(this).parent().hide()" aria-label="Close">
                    <span aria-hidden="true">
                        &times;
                    </span>
                </button>

                <h4>
                    ${flash.message}
                </h4>

                <p>
                    Please contact
                    <a href="mailto:info@elurikkus.ut.ee?subject=biocache error" style="text-decoration: underline;">
                        support
                    </a>
                    if this error continues
                </p>
            </div>
        </g:if>

        <g:if test="${errors}">
            <div class="searchInfo searchError">
                <h2 style="padding-left: 10px;">
                    <g:message code="list.01.error" />
                </h2>

                <h4>
                    ${errors}
                </h4>

                Please contact
                    <a href="mailto:info@elurikkus.ut.ee?subject=biocache error">
                        support
                    </a>
                if this error continues
            </div>
        </g:if>

        <g:elseif test="${!sr || sr.totalRecords == 0}">
            <div class="searchInfo searchError">
                <g:if test="${queryDisplay =~ /lsid/ && params.taxa}"> <!-- ${raw(queryDisplay)} -->
                    <g:if test="${queryDisplay =~ /span/}">
                        <p>
                            <g:message code="list.norecords" />

                            <span class="queryDisplay">
                                ${raw(queryDisplay.replaceAll('null:',''))}
                            </span>
                        </p>
                    </g:if>

                    <g:else>
                        <p>
                            <g:message code="list.norecords" />

                            <span class="queryDisplay">
                                ${params.taxa}
                            </span>
                        </p>
                    </g:else>

                    <p>
                        <g:message code="list.tryingsearch" />

                        <a href="?q=text:${params.taxa}">
                            <g:message code="list.02.p03.02" />: ${params.taxa}
                        </a>
                    </p>
                </g:if>

                <g:elseif test="${queryDisplay =~ /text: / && queryDisplay =~ /\s+/ && !(queryDisplay =~ /\bOR\b/)}">
                    <p>
                        <g:message code="list.norecords" />

                        <span class="queryDisplay">
                            ${raw(queryDisplay)}
                        </span>
                    </p>

                    <g:set var="queryTerms" value="${queryDisplay.split(" ")}" />

                    <p>
                        <g:message code="list.tryingsearch" />

                        <a href="?q=${queryTerms.join(" OR ")}">
                            ${queryTerms.join(" OR ")}
                        </a>
                    </p>
                </g:elseif>

                <g:else>
                    <p>
                        <g:message code="list.norecords" />

                        <span class="queryDisplay">
                            ${raw(queryDisplay) ?: params.q}
                        </span>
                    </p>
                </g:else>
            </div>
        </g:elseif>

        <g:else>
            <%-- first row (#searchInfoRow), contains customise facets button and number of results for query, etc.  --%>
            <div class="row" id="searchInfoRow">
                <%-- Results column --%>
                <div class="col">
                    <g:if test="${grailsApplication.config.useDownloadPlugin?.toBoolean()}">
                        <a
                            href="${g.createLink(uri: '/download')}?searchParams=${sr?.urlParameters?.encodeAsURL()}&targetUri=${(request.forwardURI)}"
                            class="tooltips newDownload"
                            title="Download all ${g.formatNumber(number: sr.totalRecords, format: "#,###,###")} records"
                        >
                            <%-- XXX BUTTON INSIDE LINK --%>
                            <button id="downloads" class="erk-button erk-button--light">
                                <span class="fa fa-download"></span>
                                <g:message code="general.btn.download.label" />
                            </button>
                        </a>
                    </g:if>

                    <div id="resultsReturned" class="search-section">
                        <g:render template="sandboxUploadSourceLinks" model="[dataResourceUid: selectedDataResource]" plugin="elurikkus-biocache-hubs" />

                        <form action="${g.createLink(controller: 'occurrences', action: 'search')}" id="solrSearchForm">
                            <div class="input-plus">
                                <input type="text" id="taxaQuery" name="${searchQuery}" class="input-plus__field" value="${params.list(searchQuery).join(' OR ')}" />

                                <button type="submit" id="solrSubmit" class="erk-button erk-button--dark input-plus__addon">
                                    <span class="fa fa-search"></span>
                                    <g:message code="advancedsearch.button.submit" />
                                </button>
                            </div>
                        </form>

                        <p>
                            <span id="returnedText">
                                <strong>
                                    <g:formatNumber number="${sr.totalRecords}" format="#,###,###" />
                                </strong>
                                <g:message code="list.resultsreturned.returnedtext" />
                            </span>

                            <span class="queryDisplay">
                                <strong>
                                    <g:if test="${queryDisplay == '[all records]'}">
                                        <g:message code="list.resultsreturned.allrecords" />
                                    </g:if>

                                    <g:else>
                                        ${raw(queryDisplay)}
                                    </g:else>
                                </strong>
                            </span>
                        </p>

                        <g:if test="${sr.activeFacetMap?.size() > 0 || params.wkt || params.radius}">
                            <g:render template="activeFilters" />
                        </g:if>

                        <%-- XXX XXX XXX jQuery template used for taxon drop-downs --%>
                        <div class="btn-group invisible" id="dropdown-template" style="display: none;">
                            <a
                                class="erk-button erk-button--light"
                                href=""
                                id="taxa_"
                                title="${message(code: 'list.resultsreturned.speciesLink.title')}"
                                target="BIE"
                            >
                                <g:message code="list.resultsreturned.navigator01" />
                            </a>

                            <button
                                class="erk-button erk-button--light dropdown-toggle"
                                data-toggle="dropdown"
                                title="${message(code: 'list.resultsreturned.speciesLink.title')}"
                            >
                                <span class="caret"></span>
                            </button>

                            <div class="dropdown-menu" aria-labelledby="taxa_">
                                <div class="taxaMenuContent">
                                    <g:message code="list.resultsreturned.des01" />
                                    <b class="nameString">
                                        <g:message code="list.resultsreturned.navigator01" />
                                    </b>
                                    (<span class="speciesPageLink">
                                        <g:message code="list.resultsreturned.des03" />
                                    </span>).

                                    <form
                                        name="raw_taxon_search"
                                        class="rawTaxonSearch"
                                        action="${request.contextPath}/occurrences/search/taxa"
                                        method="POST"
                                    >
                                        <div class="refineTaxaSearch">
                                            <g:message code="list.resultsreturned.form.des01" />:

                                            <input
                                                type="submit"
                                                class="erk-button erk-button--light rawTaxonSumbit"
                                                value="${message(code: 'list.resultsreturned.form.label')}"
                                                title="${message(code: 'list.resultsreturned.form.title')}"
                                            />
                                            <div class="rawTaxaList">
                                                <g:message code="list.resultsreturned.form.placeholder" />
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>  <%-- /#searchInfoRow --%>

            <%--  Second row - facet column and results column --%>
            <div class="row" id="content">
                <%-- Refine info --%>
                <div class="col-sm-4 col-md-5 col-lg-3">
                    <div class="row">
                        <div class="col">
                            <p>
                                <span class="fa fa-info-circle"></span>
                                <alatag:message code="search.filter.customise.title" />
                            </p>
                        </div>
                    </div>
                </div>

                <%-- Filters --%>
                <div class="col-sm-4 col-md-5 col-lg-3 order-sm-2">
                    <div class="card card-body filters-container">
                        <div id="filters-selection" class="dropdown">
                            <button
                                type="button"
                                id="customiseFiltersButton"
                                data-toggle="dropdown"
                                aria-haspopup="true"
                                aria-expanded="false"
                                class="erk-button erk-button--light dropdown-toggle tooltips text-nowrap"
                                title="${message(code: 'search.filter.title')}"
                            >
                                <g:message code="search.filter.customise.label" />
                                <span class="caret"></span>
                            </button>

                            <g:render template="filters" />
                        </div>

                        <g:render template="facets" />
                    </div>
                </div>

                <%-- Buttons --%>
                <div class="col-sm-8 col-md-7 col-lg-9"></div>

                <%-- Search results --%>
                <div class="col-sm-8 col-md-7 col-lg-9 order-sm-2">
                    <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
                        <div
                            id="alert"
                            class="modal fade invisible"
                            tabindex="-1"
                            role="dialog"
                            aria-labelledby="alertLabel"
                            aria-hidden="true"
                        >
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h3 id="myModalLabel">
                                            <g:message code="list.alert.title" />
                                        </h3>
                                    </div>

                                    <div class="modal-body">
                                        <div class="">
                                            <a
                                                href="#alertNewRecords"
                                                id="alertNewRecords"
                                                class="erk-button erk-button--light tooltips"
                                                data-method="createBiocacheNewRecordsAlert"
                                                title="Notify me when new records come online for this search"
                                            >
                                                <g:message code="list.alert.navigator01" />
                                            </a>
                                        </div>

                                        <br />

                                        <div class="">
                                            <a
                                                href="#alertNewAnnotations"
                                                id="alertNewAnnotations"
                                                data-method="createBiocacheNewAnnotationsAlert"
                                                class="erk-button erk-button--light tooltips"
                                                title="Notify me when new annotations (corrections, comments, etc) come online for this search"
                                            >
                                                <g:message code="list.alert.navigator02" />
                                            </a>
                                        </div>

                                        <%-- XXX --%>
                                        <p>
                                            &nbsp;
                                        </p>

                                        <p>
                                            <a href="${grailsApplication.config.alerts.baseUrl}/notification/myAlerts">
                                                <g:message code="list.alert.navigator03" />
                                            </a>
                                        </p>
                                    </div>

                                    <div class="modal-footer">
                                        <button class="btn" data-dismiss="modal" aria-hidden="true">
                                            <g:message code="show.button.close" />
                                        </button>

                                        <%--
                                            <button class="erk-button erk-button--light">
                                                Save changes
                                            </button>
                                        --%>
                                    </div>
                                </div>
                            </div>
                        </div>  <%-- /#alerts --%>
                    </g:if>

                    <%--- XXX ---%>
                    <div style="display:none"></div>

                    <div class="tabbable">
                        <ul class="nav nav-tabs">
                            <li class="nav-item active">
                                <a id="t1" href="#tab-records" data-toggle="tab" class="nav-link">
                                    <g:message code="list.records.label" />
                                </a>
                            </li>

                            <li class="nav-item">
                                <a id="t2" href="#tab-map" data-toggle="tab" class="nav-link">
                                    <g:message code="map.map.label" />
                                </a>
                            </li>

                            <plugin:isAvailable name="elurikkus-charts">
                                <li class="nav-item">
                                    <a id="t3" href="#tab-charts" data-toggle="tab" class="nav-link">
                                        <g:message code="list.link.t3" />
                                    </a>
                                </li>
                            </plugin:isAvailable>

                            <g:if test="${hasImages}">
                                <li class="nav-item">
                                    <a id="t5" href="#tab-images" data-toggle="tab" class="nav-link">
                                        <g:message code="list.link.t5" />
                                    </a>
                                </li>
                            </g:if>
                        </ul>
                    </div>

                    <div class="tab-content clearfix">
                        <div id="tab-records" role="tabpanel" class="tab-pane solrResults active" >
                            <div class="float-left">
                                <g:if test="${!grailsApplication.config.useDownloadPlugin?.toBoolean()}">
                                    <button
                                        id="downloads"
                                        data-toggle="modal"
                                        data-target="#download"
                                        class="erk-button erk-button--light"
                                    >
                                       <span class="fa fa-download"></span>
                                       <g:message code="general.btn.download.label" />
                                    </button>
                                </g:if>

                                <%-- XXX Not going to alert anyone right now.
                                <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
                                    <div id="alerts" class="erk-button erk-button--light">
                                        <a href="#alert" role="button" data-toggle="modal" class="tooltips" title="Get email alerts for this search">
                                            <span class="fa fa-bell"></span>
                                            <g:message code="list.alerts.navigator" />
                                        </a>
                                    </div>
                                </g:if>
                                --%>
                            </div>

                            <div class="inline-controls inline-controls--right">
                                <g:set var="useDefault" value="${!params.sort && !params.dir}" />

                                <div class="inline-controls__group">
                                    <label for="per-page">
                                        <g:message code="general.list.pageSize.label" />
                                    </label>

                                    <select id="per-page" name="per-page">
                                        <g:set var="pageSizeVar" value="${params.pageSize ?: params.max ?: '20'}" />
                                        <option value="10" <g:if test="${pageSizeVar == "10"}">selected</g:if>>10</option>
                                        <option value="20" <g:if test="${pageSizeVar == "20"}">selected</g:if>>20</option>
                                        <option value="50" <g:if test="${pageSizeVar == "50"}">selected</g:if>>50</option>
                                        <option value="100" <g:if test="${pageSizeVar == "100"}">selected</g:if>>100</option>
                                    </select>
                                </div>

                                <div class="inline-controls__group">
                                    <label for="sort">
                                        <g:message code="general.list.sortBy.label" />
                                    </label>

                                    <select id="sort" name="sort">
                                        <option value="score" <g:if test="${params.sort == 'score'}">selected</g:if>>
                                            <g:message code="list.sortwidgets.sort.option01" />
                                        </option>
                                        <option value="taxon_name" <g:if test="${params.sort == 'taxon_name'}">selected</g:if>>
                                            <g:message code="list.sortwidgets.sort.option02" />
                                        </option>
                                        <option value="common_name" <g:if test="${params.sort == 'common_name'}">selected</g:if>>
                                            <g:message code="list.sortwidgets.sort.option03" />
                                        </option>
                                        <option value="occurrence_date" <g:if test="${useDefault || params.sort == 'occurrence_date'}">selected</g:if>>
                                            ${skin == 'avh' ? g.message(code:"list.sortwidgets.sort.option0401") : g.message(code:"list.sortwidgets.sort.option0402")}
                                        </option>
                                        <g:if test="${skin != 'avh'}">
                                            <option value="record_type" <g:if test="${params.sort == 'record_type'}">selected</g:if>>
                                                <g:message code="list.sortwidgets.sort.option05" />
                                            </option>
                                        </g:if>
                                        <option value="first_loaded_date" <g:if test="${params.sort == 'first_loaded_date'}">selected</g:if>>
                                            <g:message code="list.sortwidgets.sort.option06" />
                                        </option>
                                        <option value="last_assertion_date" <g:if test="${params.sort == 'last_assertion_date'}">selected</g:if>>
                                            <g:message code="list.sortwidgets.sort.option07" />
                                        </option>
                                    </select>
                                </div>

                                <div class="inline-controls__group">
                                    <label for="dir">
                                        <g:message code="general.list.sortBy.label" />
                                    </label>

                                    <select id="dir" name="dir">
                                        <option value="asc" <g:if test="${params.dir == 'asc'}">selected</g:if>>
                                            <g:message code="general.list.sortOrder.asc" />
                                        </option>
                                        <option value="desc" <g:if test="${useDefault || params.dir == 'desc'}">selected</g:if>>
                                            <g:message code="general.list.sortOrder.desc" />
                                        </option>
                                    </select>
                                </div>
                            </div>

                            <div id="results" class="search-results">
                                <g:set var="startList" value="${System.currentTimeMillis()}" />

                                <%-- SEARCH RESULTS TABLE --%>
                                <table id="search-results-table" class="search-results-table">
                                    <alatag:formatOccurrencesTable occurrences="${sr.occurrences}" />
                                </table>
                            </div>

                            <%--
                               Button to expand or contract search resutls table to control the visibility
                               of overflowing columns.
                            --%>
                            <button
                                id="search-results-expand-btn"
                                class="search-results-expand-btn"
                                title="${message(code: 'listtable.expandbutton.title')}"
                                onclick="occTableHandler.toggleTableExpansion()"
                            >
                                <span
                                    id="search-results-expand-btn-icon"
                                    class="search-results-expand-btn__icon fa fa-angle-right"
                                >
                                </span>
                            </button>

                            <div id="searchNavBar" class="pagination">
                                <g:paginate
                                    total="${sr.totalRecords}"
                                    max="${sr.pageSize}"
                                    offset="${sr.startIndex}"
                                    omitLast="true"
                                    next="${message(code: 'general.paginate.next')}"
                                    prev="${message(code: 'general.paginate.prev')}&nbsp;"
                                    params="${[taxa:params.taxa, q:params.q, fq:params.fq, sort:sortField, dir:sortDir, wkt:params.wkt, lat:params.lat, lon:params.lon, radius:params.radius]}"
                                />
                            </div>
                        </div>  <%-- end solrResults --%>

                        <div id="tab-map" role="tabpanel" class="tab-pane">
                            <g:render template="map"
                                model="[
                                    mappingUrl:alatag.getBiocacheAjaxUrl(),
                                    searchString: searchString,
                                    queryDisplayString: queryDisplay,
                                    facets: sr.facetResults,
                                    defaultColourBy: grailsApplication.config.map.defaultFacetMapColourBy
                                ]"
                            />
                            <div id='envLegend'></div>
                        </div>

                        <plugin:isAvailable name="elurikkus-charts">
                            <div id="tab-charts" role="tabpanel" class="tab-pane">
                                <g:render template="charts"
                                    model="[searchString: searchString]"
                                    plugin="elurikkus-biocache-hubs"
                                />

                                <!-- Taxon pie chart -->
                                <script>
                                    var searchString = '${searchString}';

                                    taxonomyChart.load({
                                        biocacheServicesUrl: BC_CONF.biocacheServiceUrl,
                                        displayRecordsUrl: BC_CONF.serverName,
                                        instanceUid: '',
                                        rank: 'kingdom',
                                        query: searchString.replace('?q=', '')
                                    });
                                </script>
                            </div>
                        </plugin:isAvailable>

                        <g:if test="${hasImages}">
                            <div id="tab-images" role="tabpanel" class="tab-pane">
                                <div id="imagesGrid">
                                    <g:message code="list.speciesgallerycontrols.imagesgrid" />&hellip;
                                </div>

                                <div id="loadMoreImages" style="display:none;">
                                    <button class="erk-button erk-button--light">
                                        <g:message code="general.btn.loadMore" />
                                        <g:img
                                            plugin="elurikkus-biocache-hubs"
                                            dir="images"
                                            file="spinner.gif"
                                            style="display:none;"
                                            alt="indicator icon"
                                        />
                                     </button>
                                 </div>

                                <%--
                                    XXX
                                    HTML template used by AJAX code.
                                    This one is for gallery thumbnails.
                                --%>
                                <div class="gallery-thumb-template" style="display: none;">
                                    <div class="gallery-thumb">
                                        <a class="cbLink" href="" data-toggle="lightbox">
                                            <img
                                                class="gallery-thumb__img"
                                                src=""
                                                alt="${tc?.taxonConcept?.nameString} image thumbnail"
                                            />
                                            <div class="gallery-thumb__footer"></div>
                                        </a>
                                    </div>
                                </div>

                                <%--
                                    XXX
                                    HTML template used by AJAX code.
                                    This one is for image icons in search resutls table.
                                --%>
                                <div class="gallery-icon-template" style="display: none;">
                                    <a class="cbLink" href="" data-toggle="lightbox">
                                        <span class="fa fa-image"></span>
                                    </a>
                                </div>
                            </div>
                        </g:if>
                    </div>

                    <form
                        name="raw_taxon_search"
                        class="rawTaxonSearch"
                        id="rawTaxonSearchForm"
                        action="${request.contextPath}/occurrences/search/taxa"
                        method="POST"
                    >
                        <%-- taxon concept search drop-down div are put in here via Jquery --%>
                        <div style="display:none;"></div>
                    </form>
                </div>
            </div>

            <g:render template="download" />

            <div id="imageDialog" class="modal fade" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-body">
                            <div id="viewerContainerId"></div>
                        </div>
                    </div>
                </div>
            </div>
        </g:else>
    </body>
</html>
