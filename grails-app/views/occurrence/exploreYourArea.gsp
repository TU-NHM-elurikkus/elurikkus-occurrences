<%--
  - Copyright (C) 2014 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
--%>
<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 4/03/2014
  Time: 4:39 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="biocacheServiceUrl" value="${grailsApplication.config.biocache.baseUrl}"/>
<g:set var="queryContext" value="${grailsApplication.config.biocache.queryContext}"/>

<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="section" content="yourArea"/>
    <title><g:message code="eya.title01"/> | <g:message code="eya.title02"/></title>

    <g:render template="/layouts/global" plugin="biocache-hubs"/>

    <g:if test="${grailsApplication.config.google.apikey}">
        <script src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>
    </g:if>
    <g:else>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    </g:else>

    <r:require modules="exploreArea, qtip"/>
</head>

<body class="nav-locations explore-your-area">
    <div class="page-header">
        <h1 class="page-header__title">
            <g:message code="eya.title01"/>
        </h1>

        <div class="page-header__subtitle">
            Search for records in eElurikkus
        </div>

        <div class="page-header-links">
            <span id="viewAllRecords" class="erk-link page-header-links__link">
                <g:message code="eya.searchform.a.viewallrecords.01"/>

                <span id="recordsGroupText">
                    <g:message code="eya.searchform.a.viewallrecords.02" />
                </span>

                <g:message code="eya.searchform.a.viewallrecords.03" />
            </span>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <%-- RESULTS --%>
            <div class="float-left">
                <%-- SEARCH INPUT --%>
                <form name="searchForm" id="searchForm" action="" method="GET" class="form-group">
                    <div class="input-plus">
                        <input
                            type="text"
                            name="address"
                            id="address"
                            placeholder="<g:message code="eya.searchform.des01" />"
                            class="input-plus__field"
                        />

                        <button type="submit" id="locationSearch" class="erk-button erk-button--dark input-plus__addon">
                            <g:message code="advancedsearch.button.submit" />
                        </button>
                    </div>

                    <input type="hidden" name="latitude" id="latitude" value="${latitude}"/>
                    <input type="hidden" name="longitude" id="longitude" value="${longitude}"/>
                    <input type="hidden" name="location" id="location" value="${location}"/>

                    <g:if test="${true || location}">
                        <g:message code="eya.searchform.label02" />:

                        <span id="markerAddress">${location}</span>&nbsp;&nbsp;

                        <a href="#" id="addressHelp" style="text-decoration: none">
                            <span class="help-container">&nbsp;</span>
                        </a>
                    </g:if>
                </form>
            </div>

            <div class="form-linline float-right">
                <p>
                    <g:message code="eya.searchformradius.label01"/>

                    <select id="radius" name="radius" class="">
                        <option value="1" <g:if test="${radius == 1}">selected</g:if>>1</option>
                        <option value="5" <g:if test="${radius == 5}">selected</g:if>>5</option>
                        <option value="10" <g:if test="${radius == 10}">selected</g:if>>10</option>
                    </select>

                    <g:message code="eya.searchformradius.label02"/>

                    <button data-toggle="modal" data-target="#download" class="erk-button erk-button--light">
                        <i class="icon-download"></i>
                        <g:message code="download.download.title"/>
                    </button>
                </p>
            </div>

            %{-- TODO XXX --}%
            <div id="dialog-confirm" title="Continue with download?" style="display: none">
                <p>
                    %{-- TODO XXX --}%
                    <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
                    <g:message code="eya.dialogconfirm01" />
                    <span id="rad"></span>
                    <g:message code="eya.dialogconfirm02" />
                    <code>${location}</code>.<br/>
                    <g:message code="eya.dialogconfirm03" />
                </p>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xs-12 col-md-7 col-lg-5">
            <div id="taxaBox">
                <div id="leftList">
                    <table id="taxa-level-0">
                        <thead>
                            <tr>
                                <th><g:message code="eya.table.01.th01"/></th>
                                <th><g:message code="eya.table.01.th02"/></th>
                            </tr>
                        </thead>

                        <tbody></tbody>
                    </table>
                </div>

                <div id="rightList" class="tableContainer">
                    <table>
                        <thead class="fixedHeader">
                            <tr>
                                <th class="speciesIndex">&nbsp;&nbsp;</th>

                                <th class="sciName">
                                    <a href="0" id="speciesSort" data-sort="taxa" title="sort by taxa">
                                        <g:message code="eya.table.01.th02"/>
                                    </a>

                                    <span id="sortSeparator">:</span>

                                    <a href="0" id="commonSort" data-sort="common" title="sort by common name"><g:message code="eya.table.02.th01.a"/></a>
                                </th>

                                <th class="rightCounts">
                                    <a href="0" data-sort="count" title="sort by record count">
                                        <g:message code="eya.table.02.th02"/>
                                    </a>
                                </th>
                            </tr>
                        </thead>

                        <tbody class="scrollContent">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="col">
            %{-- TODO XXX --}%
            <div id="mapCanvas" style="width: 100%; height: 490px;"></div>

            %{-- TODO XXX --}%
            <div style="font-size:11px;width:100%;color:black;height:20px;" class="show-80">
                <table id="cellCountsLegend">
                    <tr>
                        <td style="background-color:#000; color:white; text-align:right;">
                            <g:message code="eya.table.02.th02"/>:&nbsp;
                        </td>

                        <td style="background-color:#ffff00;">1&ndash;9</td>
                        <td style="background-color:#ffcc00;">10&ndash;49</td>
                        <td style="background-color:#ff9900;">50&ndash;99</td>
                        <td style="background-color:#ff6600;">100&ndash;249</td>
                        <td style="background-color:#ff3300;">250&ndash;499</td>
                        <td style="background-color:#cc0000;">500+</td>
                    </tr>
                </table>
            </div>

            <div id="mapTips">
                <b><g:message code="eya.maptips.01"/></b>:
                <g:message code="eya.maptips.02"/>
            </div>
        </div>
    </div>

    <g:render template="/occurrence/download"/>

    <script type="text/javascript">
        // Global variables for yourAreaMap.js
        var EYA_CONF = {
            contextPath: "${request.contextPath}",
            biocacheServiceUrl: "${biocacheServiceUrl.encodeAsHTML()?:''}",
            imagesUrlPrefix: "${request.contextPath}/static/js/eya-images",
            zoom: ${zoom},
            radius: ${radius},
            speciesPageUrl: "${speciesPageUrl}",
            queryContext: "${queryContext}",
            locale: "${org.springframework.web.servlet.support.RequestContextUtils.getLocale(request)}",
            hasGoogleKey: ${grailsApplication.config.google.apikey as Boolean}
        }

        var eyaState = loadExploreArea(EYA_CONF);

        //make the taxa and rank global variable so that they can be used in the download
        var taxa = ["*"], rank = "*";
    </script>
</body>
</html>
