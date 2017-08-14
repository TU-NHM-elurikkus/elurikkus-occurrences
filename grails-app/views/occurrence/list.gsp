<%@ page contentType="text/html;charset=UTF-8" %>

<g:set var="queryDisplay" value="${sr?.queryTitle?:searchRequestParams?.displayString?:''}" />
<g:set var="searchQuery" value="${grailsApplication.config.skin.useAlaBie ? 'taxa' : 'q'}" />
<g:set var="authService" bean="authService" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="svn.revision" content="${meta(name: 'svn.revision')}" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="search" />
        <title>
            <g:message code="list.title" />: ${sr?.queryTitle?.replaceAll("<(.|\n)*?>", '')}
            |
            <g:message code="search.heading.list" />
            |
            ${grailsApplication.config.skin.orgNameLong}
        </title>

        <g:if test="${grailsApplication.config.google.apikey}">
            <script async defer src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>
        </g:if>

        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
            // single global var for app conf settings
            <g:set var="fqParamsSingleQ" value="${(params.fq) ? ' AND ' + params.list('fq')?.join(' AND ') : ''}" />

            <g:set var="fqParams" value="${(params.fq) ? "&fq=" + params.list('fq')?.join('&fq=') : ''}" />
            <g:set var="searchString" value="${raw(sr?.urlParameters).encodeAsURL()}" />
            var BC_CONF = {
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
                facetLimit: "${grailsApplication.config.facets.limit?:50}",
                queryContext: "${grailsApplication.config.biocache.queryContext}",
                selectedDataResource: "${selectedDataResource}",
                autocompleteHints: "${grailsApplication.config.bie?.autocompleteHints?.encodeAsJson()?:'{}'}",
                zoomOutsideScopedRegion: Boolean("${grailsApplication.config.map.zoomOutsideScopedRegion}"),
                hasMultimedia: ${hasImages?:'false'}, // will be either true or false
                locale: "${org.springframework.web.servlet.support.RequestContextUtils.getLocale(request)}",
                imageServiceBaseUrl:"${grailsApplication.config.images.baseUrl}",
                likeUrl: "${createLink(controller: 'imageClient', action: 'likeImage')}",
                dislikeUrl: "${createLink(controller: 'imageClient', action: 'dislikeImage')}",
                userRatingUrl: "${createLink(controller: 'imageClient', action: 'userRating')}",
                disableLikeDislikeButton: "${authService.getUserId() ? false : true}",
                addLikeDislikeButton: "${(grailsApplication.config.addLikeDislikeButton == false) ? false : true}",
                addPreferenceButton: "${authService?.getUserId() ? (authService.getUserForUserId(authService.getUserId())?.roles?.contains('ROLE_ADMIN') ? true : false) : false}",
                // whatever this is
                userRatingHelpText: `
                    <div>
                        <b>Up vote (<i class="fa fa-thumbs-o-up" aria-hidden="true"></i>) an image:</b>
                        Image supports the identification of the species or is representative of the species.  Subject is clearly visible including identifying features.
                        <br /><br />
                        <b>Down vote (<i class="fa fa-thumbs-o-down" aria-hidden="true"></i>) an image:</b>
                        Image does not support the identification of the species, subject is unclear and identifying features are difficult to see or not visible.
                        <br />
                    </div>
                `,
                savePreferredSpeciesListUrl: "${createLink(controller: 'imageClient', action: 'saveImageToSpeciesList')}",
                getPreferredSpeciesListUrl:  "${grailsApplication.config.speciesList.baseURL}" // "${createLink(controller: 'imageClient', action: 'getPreferredSpeciesImageList')}"
            };
        </script>

        <r:require modules="elurikkusSearch, leafletOverride, leafletPluginsOverride, slider, qtip, nanoscroller, amplify, moment, mapCommonOverride, image-viewer, lightbox, chartsOverride" />

        <g:if test="${grailsApplication.config.skin.useAlaBie?.toBoolean()}">
            <r:require module="bieAutocomplete" />
        </g:if>

        <script type="text/javascript">
            <g:if test="${!grailsApplication.config.google.apikey}">
                google.load('maps','3.5',{ other_params: "sensor=false" });
            </g:if>

            google.load("visualization", "1", {packages:["corechart"]});
        </script>
    </head>

    <body class="occurrence-search">
        <div id="listHeader" class="page-header">
            <h1 class="page-header__title" name="resultsTop">
                <g:message code="search.heading.list" />
            </h1>

            <div class="page-header__subtitle">
                <g:message code="home.index.subtitle" args="${['eElurikkus']}" />
            </div>

            <%-- TODO MAYBE KEEP IT MAYBE NOT --%>
            <div class="page-header-links">
                <a href="${g.createLink(uri: '/search')}#tab-advanced-search" class="page-header-links__link">
                    <g:message code="home.index.navigator02" />
                </a>

                <a href="${g.createLink(uri: '/search')}#tab-taxa-upload" class="page-header-links__link">
                    <g:message code="home.index.navigator03" />
                </a>

                <a href="${g.createLink(uri: '/search')}#tab-catalog-upload" class="page-header-links__link">
                    <g:message code="home.index.navigator04" />
                </a>

                <a href="${g.createLink(uri: '/search')}#tab-spatial-search" class="page-header-links__link">
                    <g:message code="home.index.navigator05" />
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
                    <a href="mailto:support@ala.org.au?subject=biocache error" style="text-decoration: underline;">
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
                    <a href="mailto:support@ala.org.au?subject=biocache error">
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
                            ${raw(queryDisplay)?:params.q}
                        </span>
                    </p>
                </g:else>
            </div>
        </g:elseif>

        <g:else>
            <%--  first row (#searchInfoRow), contains customise facets button and number of results for query, etc.  --%>
            <div class="row" id="searchInfoRow">
                <%-- Results column --%>
                <div class="col">
                    <%--- XXX ... XXX ---%>
                    <a name="map" class="jumpTo"></a>
                    <a name="list" class="jumpTo"></a>

                    <%-- OFF for now --%>
                    <g:if test="${false && flash.message}">
                        <div class="alert alert-info" style="margin-left: -30px;">
                            <button type="button" class="close" data-dismiss="alert">
                                &times;
                            </button>

                            ${flash.message}
                        </div>
                    </g:if>

                    <g:if test="${grailsApplication.config.useDownloadPlugin?.toBoolean()}">
                        <a
                            href="${g.createLink(uri: '/download')}?searchParams=${sr?.urlParameters?.encodeAsURL()}&targetUri=${(request.forwardURI)}"
                            class="tooltips newDownload"
                            title="Download all ${g.formatNumber(number: sr.totalRecords, format: "#,###,###")} records"
                        >
                            <%-- XXX BUTTON INSIDE LINK --%>
                            <button id="downloads" class="erk-button erk-button--light">
                                <span class="fa fa-download"></span>
                                <g:message code="download.download.label" />
                            </button>
                        </a>
                    </g:if>

                    <section id="resultsReturned" class="search-section">
                        <g:render template="sandboxUploadSourceLinks" model="[dataResourceUid: selectedDataResource]" plugin="biocache-hubs" />

                        <form action="${g.createLink(controller: 'occurrences', action: 'search')}" id="solrSearchForm">
                            <div class="input-plus">
                                <input type="text" id="taxaQuery" name="${searchQuery}" class="input-plus__field" value="${params.list(searchQuery).join(' OR ')}" />

                                <button type="submit" id="solrSubmit" class="erk-button erk-button--dark input-plus__addon">
                                    <g:message code="advancedsearch.button.submit" />
                                </button>
                            </div>
                        </form>

                        <p>
                            <span id="returnedText">
                                <strong>
                                    <g:formatNumber number="${sr.totalRecords}" format="#,###,###" />
                                </strong>
                                <g:message code="list.resultsretuened.returnedtext" />
                            </span>

                            <span class="queryDisplay">
                                <strong>
                                    ${raw(queryDisplay)}
                                </strong>
                            </span>
                        </p>

                        <%--
                            What is this?
                            <g:set var="hasFq" value="${false}" />
                        --%>

                        <g:if test="${sr.activeFacetMap?.size() > 0 || params.wkt || params.radius}">
                            <g:render template="activeFilters" />
                        </g:if>

                        <%-- XXX XXX XXX jQuery template used for taxon drop-downs --%>
                        <div class="btn-group invisible" id="template" style="display: none;">
                            <a class="erk-button erk-button--light" href="" id="taxa_" title="${message(code: 'list.resultsretuened.speciesLink.title')}" target="BIE">
                                <g:message code="list.resultsretuened.navigator01" />
                            </a>

                            <button class="erk-button erk-button--light dropdown-toggle" data-toggle="dropdown" title="${message(code: 'list.resultsretuened.speciesLink.title')}">
                                <span class="caret"></span>
                            </button>

                            <div class="dropdown-menu" aria-labelledby="taxa_">
                                <div class="taxaMenuContent">
                                    <g:message code="list.resultsretuened.des01" />
                                    <b class="nameString">
                                        <g:message code="list.resultsretuened.navigator01" />
                                    </b>
                                    (<span class="speciesPageLink">
                                        <g:message code="list.resultsretuened.des03" />
                                    </span>).

                                    <form name="raw_taxon_search" class="rawTaxonSearch" action="${request.contextPath}/occurrences/search/taxa" method="POST">
                                        <div class="refineTaxaSearch">
                                            <g:message code="list.resultsretuened.form.des01" />:
                                            <input
                                                type="submit"
                                                class="erk-button erk-button--light rawTaxonSumbit"
                                                value="<g:message code='list.resultsretuened.form.label' />"
                                                title="<g:message code='list.resultsretuened.form.title' />"
                                            />
                                            <div class="rawTaxaList">
                                                <g:message code="list.resultsretuened.form.placeholder" />
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>
            </div><!-- /#searchInfoRow -->

            <%--  Second row - facet column and results column --%>
            <div class="row" id="content">
                <div class="col-sm-5 col-md-3">
                    <div class="card card-block filters-container">
                        <div id="filters-selection" class="dropdown">
                            <h2 class="card-title">
                                <alatag:message code="search.filter.customise.title" />
                            </h2>

                            <button
                                type="button"
                                id="customiseFiltersButton"
                                data-toggle="dropdown"
                                aria-haspopup="true"
                                aria-expanded="false"
                                class="erk-button erk-button--light dropdown-toggle tooltips text-nowrap"
                                title="${message(code: 'search.filter.title')}"
                            >
                                <span class="fa fa-cog"></span>

                                <g:message code="search.filter.customise.label" />

                                <span class="caret"></span>
                            </button>

                            <g:render template="filters" />
                        </div>

                        <g:render template="facets" />
                    </div>
                </div>

                <g:set var="postFacets" value="${System.currentTimeMillis()}" />

                <!-- removed id of content 2 -->
                <div class="col-sm-7 col-md-9">
                    <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
                        <div id="alert" class="modal fade invisible" tabindex="-1" role="dialog" aria-labelledby="alertLabel" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                            ×
                                        </button>
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
                                        <p>&nbsp;</p>

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

                    <g:render template="download" />

                    <%--- XXX ---%>
                    <div style="display:none"></div>

                    <div class="tabbable">
                        <ul class="nav nav-tabs">
                            <li class="nav-item active">
                                <a id="t1" href="#records" data-toggle="tab" class="nav-link">
                                    <g:message code="list.records.label" />
                                </a>
                            </li>

                            <li class="nav-item">
                                <a id="t2" href="#map" data-toggle="tab" class="nav-link">
                                    <g:message code="map.map.label" />
                                </a>
                            </li>

                            <plugin:isAvailable name="alaChartsPlugin">
                                <li class="nav-item">
                                    <a id="t3" href="#charts" data-toggle="tab" class="nav-link">
                                        <g:message code="list.link.t3" />
                                    </a>
                                </li>

                                <g:if test="${grailsApplication.config.userCharts && grailsApplication.config.userCharts.toBoolean()}">
                                    <li class="nav-item">
                                        <a id="t6" href="#userChartsView" data-toggle="tab" class="nav-link">
                                            <g:message code="list.link.t6" />
                                        </a>
                                    </li>
                                </g:if>
                            </plugin:isAvailable>

                            <g:if test="${showSpeciesImages}">
                                <li class="nav-item">
                                    <a id="t4" href="#speciesImages" data-toggle="tab" class="nav-link">
                                        <g:message code="list.link.t4" />
                                    </a>
                                </li>
                            </g:if>

                            <g:if test="${hasImages}">
                                <li class="nav-item">
                                    <a id="t5" href="#images" data-toggle="tab" class="nav-link">
                                        <g:message code="list.link.t5" />
                                    </a>
                                </li>
                            </g:if>
                        </ul>
                    </div>

                    <div class="tab-content clearfix">
                        <div id="records" role="tabpanel" class="tab-pane solrResults active" >
                            <div class="search-controls">
                                <g:if test="${!grailsApplication.config.useDownloadPlugin?.toBoolean()}">
                                    <button id="downloads" data-toggle="modal" data-target="#download" class="erk-button erk-button--light">
                                       <span class="fa fa-download"></span>
                                       <g:message code="download.download.label" />
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

                                <form class="form-inline float-right">
                                    <g:set var="useDefault" value="${(!params.sort && !params.dir) ? true : false }" />

                                    <div class="form-group">
                                        <label for="per-page">
                                            <g:message code="list.table.resultsPerPage.label" />
                                        </label>

                                        <select id="per-page" name="per-page">
                                            <g:set var="pageSizeVar" value="${params.pageSize?:params.max?:"20"}" />
                                            <option value="10" <g:if test="${pageSizeVar == "10"}">selected</g:if>>10</option>
                                            <option value="20" <g:if test="${pageSizeVar == "20"}">selected</g:if>>20</option>
                                            <option value="50" <g:if test="${pageSizeVar == "50"}">selected</g:if>>50</option>
                                            <option value="100" <g:if test="${pageSizeVar == "100"}">selected</g:if>>100</option>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="sort">
                                            <g:message code="list.table.sortBy.label" />
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
                                            <option value="occurrence_date" <g:if test="${params.sort == 'occurrence_date'}">selected</g:if>>
                                                ${skin == 'avh' ? g.message(code:"list.sortwidgets.sort.option0401") : g.message(code:"list.sortwidgets.sort.option0402")}
                                            </option>
                                            <g:if test="${skin != 'avh'}">
                                                <option value="record_type" <g:if test="${params.sort == 'record_type'}">selected</g:if>>
                                                    <g:message code="list.sortwidgets.sort.option05" />
                                                </option>
                                            </g:if>
                                            <option value="first_loaded_date" <g:if test="${useDefault || params.sort == 'first_loaded_date'}">selected</g:if>>
                                                <g:message code="list.sortwidgets.sort.option06" />
                                            </option>
                                            <option value="last_assertion_date" <g:if test="${params.sort == 'last_assertion_date'}">selected</g:if>>
                                                <g:message code="list.sortwidgets.sort.option07" />
                                            </option>
                                        </select>
                                        &nbsp;
                                    </div>

                                    <div class="form-group">
                                        <label for="dir">
                                            <g:message code="list.table.sortOrder.label" />
                                        </label>

                                        <select id="dir" name="dir">
                                            <option value="asc" <g:if test="${params.dir == 'asc'}">selected</g:if>>
                                                <g:message code="list.sortwidgets.dir.option01" />
                                            </option>
                                            <option value="desc" <g:if test="${useDefault || params.dir == 'desc'}">selected</g:if>>
                                                <g:message code="list.sortwidgets.dir.option02" />
                                            </option>
                                        </select>
                                    </div>
                                </form>
                            </div>

                            <div id="results" class="search-results">
                                <g:set var="startList" value="${System.currentTimeMillis()}" />

                                <g:each var="occurrence" in="${sr.occurrences}">
                                    <alatag:formatListRecordRow occurrence="${occurrence}" />
                                </g:each>
                            </div>

                            <div id="searchNavBar" class="pagination">
                                <g:paginate
                                    total="${sr.totalRecords}"
                                    max="${sr.pageSize}"
                                    offset="${sr.startIndex}"
                                    omitLast="true"
                                    next="${message(code: 'list.paginate.next')}"
                                    prev="${message(code: 'list.paginate.prev')}&nbsp;"
                                    params="${[taxa:params.taxa, q:params.q, fq:params.fq, wkt:params.wkt, lat:params.lat, lon:params.lon, radius:params.radius]}"
                                />
                            </div>
                        </div>  <%-- end solrResults --%>

                        <div id="map" role="tabpanel" class="tab-pane">
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

                        <plugin:isAvailable name="alaChartsPlugin">
                            <div id="charts" role="tabpanel" class="tab-pane">
                                <g:render template="charts"
                                    model="[searchString: searchString]"
                                    plugin="biocache-hubs"
                                />

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

                            <g:if test="${grailsApplication.config.userCharts && grailsApplication.config.userCharts?.toBoolean()}">
                                <div id="userChartsView" role="tabpanel" class="tab-pane">
                                    <g:render template="userCharts"
                                        model="[searchString: searchString]"
                                        plugin="biocache-hubs" />
                                </div>
                            </g:if>
                        </plugin:isAvailable>

                        <g:if test="${showSpeciesImages}">
                            <div id="speciesImages" role="tabpanel" class="tab-pane">
                                <h3>
                                    <g:message code="list.speciesimages.title" />
                                </h3>
                                <div id="speciesGalleryControls">
                                    <g:message code="list.speciesgallerycontrols.label.01" />
                                    <select id="speciesGroup">
                                        <option>
                                            <g:message code="list.speciesgallerycontrols.speciesgroup.option01" />
                                        </option>
                                    </select>
                                    &nbsp;
                                    <g:message code="list.speciesgallerycontrols.label.02" />
                                    <select id="speciesGallerySort">
                                        <option value="common">
                                            <g:message code="list.speciesgallerycontrols.speciesgallerysort.option01" />
                                        </option>
                                        <option value="taxa">
                                            <g:message code="list.speciesgallerycontrols.speciesgallerysort.option02" />
                                        </option>
                                        <option value="count">
                                            <g:message code="list.speciesgallerycontrols.speciesgallerysort.option03" />
                                        </option>
                                    </select>
                                </div>

                                <div id="speciesGallery">
                                    [<g:message code="list.speciesgallerycontrols.speciesgallery" />]
                                </div>

                                <%-- XXX --%>
                                <div id="loadMoreSpecies" style="display:none;">
                                    <button class="erk-button erk-button--light">
                                        <g:message code="list.speciesgallerycontrols.loadmorespecies.button" />
                                    </button>
                                    <g:img plugin="biocache-hubs" dir="images" file="indicator.gif" style="display:none;" alt="indicator icon" />
                                </div>
                            </div> <%-- end #speciesWrapper --%>
                        </g:if>

                        <g:if test="${hasImages}">
                            <div id="images" role="tabpanel" class="tab-pane">
                                <%-- <p>
                                    (see also <a href="#tab_speciesImages">representative species images</a>)
                                </p> --%>

                                <div id="imagesGrid">
                                    <g:message code="list.speciesgallerycontrols.imagesgrid" />...
                                </div>

                                <div id="loadMoreImages" style="display:none;">
                                    <p>
                                        <button class="erk-button erk-button--light">
                                            <g:message code="list.speciesgallerycontrols.loadmoreimages.button" />
                                            <g:img plugin="biocache-hubs" dir="images" file="indicator.gif" style="display:none;" alt="indicator icon" />
                                         </button>
                                     </p>
                                 </div>

                                <%-- HTML template used by AJAX code --%>
                                <div class="imgConTmpl" style="display: none;">
                                    <div class="imgCon">
                                        <a class="cbLink" rel="thumbs" href="" id="thumb">
                                            <img src="" alt="${tc?.taxonConcept?.nameString} image thumbnail" />
                                            <div class="meta brief"></div>
                                            <div class="meta detail invisible"></div>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </g:if>
                    </div>

                    <form name="raw_taxon_search" class="rawTaxonSearch" id="rawTaxonSearchForm" action="${request.contextPath}/occurrences/search/taxa" method="POST">
                        <%-- taxon concept search drop-down div are put in here via Jquery --%>
                        <div style="display:none;" ></div>
                    </form>
                </div>
            </div>
        </g:else>

        <div id="imageDialog" class="modal fade" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-body">
                        <div id="viewerContainerId"></div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
