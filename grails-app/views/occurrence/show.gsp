<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:set var="recordId" value="${alatag.getRecordId(record: record, skin: skin)}" />
<g:set var="bieWebappContext" value="${grailsApplication.config.bie.baseUrl}" />
<g:set var="collectionsWebappContext" value="${grailsApplication.config.collections.baseUrl}" />
<g:set var="useAla" value="${grailsApplication.config.skin.useAlaBie?.toBoolean() ? 'true' : 'false'}" />
<g:set var="taxaLinks" value="${grailsApplication.config.skin.taxaLinks}" />
<g:set var="dwcExcludeFields" value="${grailsApplication.config.dwc.exclude}" />
<g:set var="hubDisplayName" value="${grailsApplication.config.skin.orgNameLong}" />
<g:set var="biocacheService" value="${alatag.getBiocacheAjaxUrl()}" />
<g:set var="spatialPortalUrl" value="${grailsApplication.config.spatial.baseUrl}" />
<g:set var="serverName" value="${grailsApplication.config.serverName}" />
<g:set var="scientificName" value="${alatag.getScientificName(record: record)}" />
<g:set var="sensitiveDatasetRaw" value="${grailsApplication.config.sensitiveDataset?.list?:''}" />
<g:set var="sensitiveDatasets" value="${sensitiveDatasetRaw?.split(',')}" />
<g:set var="userDisplayName" value="${alatag.loggedInUserDisplayname()}" />
<g:set var="userId" value="${alatag.loggedInUserId()}" />
<g:set var="isUnderCas" value="${(grailsApplication.config.security.cas.casServerName || grailsApplication.config.casServerName) ? true : false}" />

<!DOCTYPE html>
<html>
    <head>
        <meta name="svn.revision" content="${meta(name: 'svn.revision')}" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <meta name="section" content="search" />
        <title>
            <g:message code="show.title" />: ${recordId} | <g:message code="show.occurrenceRecord" /> | ${hubDisplayName}
        </title>

        <g:if test="${grailsApplication.config.google.apikey}">
            <script async defer src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>
        </g:if>
        <g:else>
            <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        </g:else>

        <script type="text/javascript">
            // Global var OCC_REC to pass GSP data to external JS file
            var OCC_REC = {
                userId: "${userId}",
                userDisplayName: "${userDisplayName}",
                contextPath: "${request.contextPath}",
                recordUuid: "${record.raw.uuid}",
                taxonRank: "${record.processed.classification.taxonRank}",
                taxonConceptID: "${record.processed.classification.taxonConceptID}",
                isUnderCas: ${isUnderCas},
                locale: "${org.springframework.web.servlet.support.RequestContextUtils.getLocale(request)}",
                sensitiveDatasets: {
                    <g:each var="sds" in="${sensitiveDatasets}"
                       status="s">'${sds}': '${grailsApplication.config.sensitiveDatasets[sds]}'${s < (sensitiveDatasets.size() - 1) ? ',' : ''}
                    </g:each>
                },
                hasGoogleKey: ${grailsApplication.config.google.apikey as Boolean}
            }

            // Google charts
            if(!OCC_REC.hasGoogleKey) {
                google.load('maps', '3.3', {other_params: "sensor=false"});
            }
        </script>

        <g:render template="/layouts/global" />

        <r:require modules="recordView, amplify, moment" />
        <r:script disposition="head">
            $(document).ready(function() {
                <g:if test="${record.processed.attribution.provenance == 'Draft'}">
                    // draft view button
                    $('#viewDraftButton').click(function() {
                        document.location.href = '${record.raw.occurrence.occurrenceID}';
                    });
                </g:if>
            }); // end $(document).ready()
        </r:script>
    </head>

    <body class="occurrence-record">
        <%-- <g:set var="json" value="${request.contextPath}/occurrences/${record?.raw?.uuid}.json" /> --%>

        <g:if test="${record}">
            <g:if test="${record.raw}">
                <%-- WIP --%>
                <div class="page-header">
                    <h1 class="page-header__title">
                        <g:if test="${collectionLogo}">
                            <img src="${collectionLogo}" alt="institution logo" id="institutionLogo" />
                        </g:if>

                        <g:message code="show.occurrenceRecord" />:
                        <span id="recordId">
                            ${recordId}
                        </span>
                    </h1>

                    <div class="page-header__subtitle">
                        <g:message code="basisOfRecord.${record.processed.occurrence?.basisOfRecord}" default="${record.processed.occurrence?.basisOfRecord}" />
                        <g:message code="show.heading.of" />

                        <g:if test="${record.processed.classification.scientificName}">
                            <alatag:formatSciName rankId="${record.processed.classification.taxonRankID}" name="${record.processed.classification.scientificName}" />
                            ${record.processed.classification.scientificNameAuthorship}
                        </g:if>

                        <g:elseif test="${record.raw.classification.scientificName}">
                            <alatag:formatSciName rankId="${record.raw.classification.taxonRankID}" name="${record.raw.classification.scientificName}" />
                            ${record.raw.classification.scientificNameAuthorship}
                        </g:elseif>

                        <g:else>
                            <i>${record.raw.classification.genus} ${record.raw.classification.specificEpithet}</i>
                            ${record.raw.classification.scientificNameAuthorship}
                        </g:else>

                        <g:if test="${record.processed.classification.vernacularName}">
                            | ${record.processed.classification.vernacularName}
                        </g:if>

                        <g:elseif test="${record.raw.classification.vernacularName}">
                            | ${record.raw.classification.vernacularName}
                        </g:elseif>

                        <g:if test="${record.processed.event?.eventDate || record.raw.event?.eventDate}">
                            <g:message code="show.heading.recordedOn" />
                            ${record.processed.event?.eventDate ?: record.raw.event?.eventDate}
                        </g:if>

                        <%-- TODO MAYBE
                        <span id="jsonLinkZ">
                            <g:if test="${isCollectionAdmin}">
                                <g:set var="admin" value=" - admin" />
                            </g:if>

                            <g:if test="${false && alatag.loggedInUserDisplayname()}">
                                <g:message code="show.jsonlink.login" />:
                                ${alatag.loggedInUserDisplayname()}
                            </g:if>

                            <g:if test="${clubView}">
                                <span id="clubView">
                                    <g:message code="show.clubview.message" />
                                </span>
                            </g:if>
                        </span>
                        --%>
                    </div>

                    <div class="page-header-links">
                        <a href="${g.createLink(uri: '/search')}" class="page-header-links__link">
                            <g:message code="home.index.title" />
                        </a>

                        <a href="#" id="backBtn" title="Return to search results" class="page-header-links__link">
                            <g:message code="show.backbtn.navigator" />
                        </a>
                    </div>
                </div>

                <div class="row">
                    <div id="SidebarBoxZ" class="col-sm-5 col-lg-3">
                        <g:render template="recordSidebar" />
                    </div>

                    <div id="content2Z" class="col-sm-7 col-lg-9">
                        <div class="float-right">
                            <g:if test="${contacts && contacts.size()}">
                                <button
                                    href="#contactCuratorView"
                                    class="erk-button erk-button--light erk-button--inline"
                                    id="showCurator"
                                    role="button"
                                    data-toggle="modal"
                                    title="${message(code: 'show.showcontactcurator.title')}"
                                >
                                    <span id="contactCuratorSpan" href="#contactCuratorView" title="">
                                        <i class="fa fa-envelope-o"></i> <g:message code="show.showcontactcurator.label" />
                                    </span>
                                </button>
                            </g:if>

                            <button
                                id="showRawProcessed"
                                data-toggle="modal"
                                href="#processedVsRawView"
                                class="erk-button erk-button--light erk-button--inline"
                                role="button"
                                title="<g:message code='show.sidebar02.showrawprocessed.title' />"
                            >
                                <span id="processedVsRawViewSpan" href="#processedVsRawView" title="">
                                    <i class="fa fa-balance-scale"></i> <g:message code="show.sidebar02.showrawprocessed.label" />
                                </span>
                            </button>
                        </div>

                        <br />

                        <g:render template="recordCore" />
                    </div>
                </div>

                <g:if test="${hasExpertDistribution}">
                    <div id="hasExpertDistribution"  class="additionalData" style="clear:both;padding-top: 20px;">
                        <h2>
                            <g:message code="show.hasexpertdistribution.title" />
                            <a id="expertReport" href="#expertReport">
                                &nbsp;
                            </a>
                        </h2>
                        <script type="text/javascript" src="${request.contextPath}/js/wms2.js"></script>
                        <script type="text/javascript">
                            $(document).ready(function() {
                                var latlng1 = new google.maps.LatLng(${latLngStr});
                                var mapOptions = {
                                    zoom: 4,
                                    center: latlng1,
                                    scrollwheel: false,
                                    scaleControl: true,
                                    streetViewControl: false,
                                    mapTypeControl: true,
                                    mapTypeControlOptions: {
                                        style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                                        mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.HYBRID, google.maps.MapTypeId.TERRAIN ]
                                    },
                                    mapTypeId: google.maps.MapTypeId.ROADMAP
                                };

                                var distroMap = new google.maps.Map(document.getElementById("expertDistroMap"), mapOptions);

                                var marker1 = new google.maps.Marker({
                                    position: latlng1,
                                    map: distroMap,
                                    title:"Occurrence Location"
                                });

                                // Attempt to display expert distribution layer on map
                                var SpatialUrl = "${spatialPortalUrl}ws/distribution/lsid/${record.processed.classification.taxonConceptID}?callback=?";
                                $.getJSON(SpatialUrl, function(data) {

                                    if (data.wmsurl) {
                                        var urlParts = data.wmsurl.split("?");

                                        if (urlParts.length == 2) {
                                            var baseUrl = urlParts[0] + "?";
                                            var paramParts = urlParts[1].split("&");
                                            loadWMS(distroMap, baseUrl, paramParts);
                                            // adjust bounds for both Aust (centre) and marker
                                            var AusCentre = new google.maps.LatLng(-27, 133);
                                            var dataBounds = new google.maps.LatLngBounds();
                                            dataBounds.extend(AusCentre);
                                            dataBounds.extend(latlng1);
                                            distroMap.fitBounds(dataBounds);
                                        }

                                    }
                                });

                                <g:if test="${record.processed.location.coordinateUncertaintyInMeters}">
                                    var radius1 = parseInt('${record.processed.location.coordinateUncertaintyInMeters}');

                                    if (!isNaN(radius1)) {
                                        // Add a Circle overlay to the map.
                                        circle1 = new google.maps.Circle({
                                            map: distroMap,
                                            radius: radius1, // 3000 km
                                            strokeWeight: 1,
                                            strokeColor: 'white',
                                            strokeOpacity: 0.5,
                                            fillColor: '#2C48A6',
                                            fillOpacity: 0.2
                                        });
                                        // bind circle to marker
                                        circle1.bindTo('center', marker1, 'position');
                                    }
                                </g:if>
                            });
                        </script>
                        <div id="expertDistroMap" style="width:80%;height:400px;margin:20px 20px 10px 0;"></div>
                    </div>
                </g:if>

                <div class="row">
                    <div class="col-12">
                        <div id="userAnnotationsDiv" class="additionalData">
                            <h2>
                                <g:message code="show.userannotations.title" />
                                <a id="userAnnotations">
                                    &nbsp;
                                </a>
                            </h2>
                            <h4>
                                <g:message code="user.assertion.status" />:
                                <i>
                                    <span id="userAssertionStatus"></span>
                                </i>
                            </h4>
                            <ul id="userAnnotationsList" style="list-style: none; margin:0;"></ul>
                        </div>

                    </div>
                </div>

                <div id="outlierFeedback">
                    <g:if test="${record.processed.occurrence.outlierForLayers}">
                        <div id="outlierInformation" class="additionalData">
                            <h2>
                                <g:message code="show.outlierinformation.title" />
                                <a id="outlierReport" href="#outlierReport">
                                    &nbsp;
                                </a>
                            </h2>
                            <p>
                                <g:message code="show.outlierinformation.p01" />
                                <a href="https://github.com/AtlasOfLivingAustralia/ala-dataquality/wiki/DETECTED_OUTLIER_JACKKNIFE">
                                    <g:message code="show.outlierinformation.p.navigator" />
                                </a>
                                <g:message code="show.outlierinformation.p02" />:
                            </p>

                            <ul>
                                <g:each in="${metadataForOutlierLayers}" var="layerMetadata">
                                    <li>
                                        <a href="${grailsApplication.config.layersservice.baseUrl}/layers/view/more/${layerMetadata.name}">
                                            ${layerMetadata.displayname} - ${layerMetadata.source}
                                        </a>
                                        <br />
                                        <g:message code="show.outlierinformation.each.label01" />: ${layerMetadata.notes}
                                        <br />
                                        <g:message code="show.outlierinformation.each.label02" />: ${layerMetadata.scale}
                                    </li>
                                </g:each>
                            </ul>

                            <p style="margin-top:20px;">
                                <g:message code="show.outlierinformation.p.label" />:

                                <ul>
                                    <li>
                                        <a href="https://github.com/AtlasOfLivingAustralia/ala-dataquality/wiki/DETECTED_OUTLIER_JACKKNIFE">
                                            https://github.com/AtlasOfLivingAustralia/ala-dataquality/wiki/DETECTED_OUTLIER_JACKKNIFE
                                        </a>
                                    </li>
                                    <li>
                                        <a href="https://docs.google.com/open?id=0B7rqu1P0r1N0NGVhZmVhMjItZmZmOS00YmJjLWJjZGQtY2Y0ZjczZmUzZTZl">
                                            <g:message code="show.outlierinformation.p.li02" />
                                        </a>
                                    </li>
                                </ul>
                            </p>
                        </div>

                        <div id="charts" style="margin-top:20px;"></div>

                        <script>
                            function renderOutlierCharts(data){
                                var chartQuery = null;

                                if (OCC_REC.taxonRank  == 'species') {
                                    chartQuery = 'species_guid:' + OCC_REC.taxonConceptID.replace(/:/,'\:');
                                } else if (OCC_REC.taxonRank  == 'subspecies') {
                                    chartQuery = 'species_guid:' + OCC_REC.taxonConceptID.replace(/:/,'\:');
                                }

                                if(chartQuery != null) {
                                    $.each(data, function() {
                                        drawChart(this.layerId, chartQuery, this.layerId, this.outlierValues, this.recordLayerValue, false);
                                        drawChart(this.layerId, chartQuery, this.layerId, this.outlierValues, this.recordLayerValue, true);
                                    })
                                }
                            }

                            function drawChart(facetName, biocacheQuery, chartName, outlierValues, valueForThisRecord, cumulative){

                                var facetChartOptions = { error: "badQuery", legend: 'right'}
                                facetChartOptions.query = biocacheQuery;
                                facetChartOptions.charts = [chartName];
                                facetChartOptions.width = "75%";
                                facetChartOptions.chartsDiv = "charts";
                                facetChartOptions[facetName] = {chartType: 'scatter'};
                                facetChartOptions.biocacheServicesUrl = "${alatag.getBiocacheAjaxUrl()}";
                                facetChartOptions.displayRecordsUrl = "${grailsApplication.config.grails.serverURL}";

                                //additional config
                                facetChartOptions.cumulative = cumulative;
                                facetChartOptions.outlierValues = outlierValues;  //retrieved from WS
                                facetChartOptions.highlightedValue = valueForThisRecord;  //retrieved from the record

                                facetChartGroup.loadAndDrawFacetCharts(facetChartOptions);
                            }
                        </script>
                        <script type="text/javascript" src="${biocacheService}/outlier/record/${uuid}.json?callback=renderOutlierCharts"></script>

                    </g:if>

    				<g:if test="${record.processed.occurrence.duplicationStatus}">
    					<div id="inferredOccurrenceDetails">
                            <a href="#inferredOccurrenceDetails" name="inferredOccurrenceDetails" id="inferredOccurrenceDetails" hidden="true"></a>
                            <h2>
                                <g:message code="show.inferredoccurrencedetails.title" />
                            </h2>
                            <p style="margin-top:5px;">
                                <g:if test="${record.processed.occurrence.duplicationStatus == 'R' }">
                                    <g:message code="show.inferredoccurrencedetails.p01" />
                                </g:if>
                                <g:else>
                                    <g:message code="show.inferredoccurrencedetails.p02" />
                                </g:else>
                                <g:message code="show.inferredoccurrencedetails.p03" />:
                                <ul>
                                    <li>
                                        <a href="https://github.com/AtlasOfLivingAustralia/ala-dataquality/wiki/INFERRED_DUPLICATE_RECORD">
                                            https://github.com/AtlasOfLivingAustralia/ala-dataquality/wiki/INFERRED_DUPLICATE_RECORD
                                        </a>
                                    </li>
                                </ul>
                            </p>
                            <g:if test="${duplicateRecordDetails && duplicateRecordDetails.duplicates?.size() > 0}">
                                <table class="duplicationTable table table-sm table-striped table-bordered" style="border-bottom:none;">
                                    <tr class="sectionName">
                                        <td colspan="4">
                                            <g:message code="show.table01.title" />
                                        </td>
                                    </tr>
                                    <g:if test="${duplicateRecordDetails.uuid}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Record UUID">
                                            <a href="${request.contextPath}/occurrences/${duplicateRecordDetails.uuid}">
                                                ${duplicateRecordDetails.uuid}
                                            </a>
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.rowKey}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Data Resource">
                                            <g:set var="dr">${duplicateRecordDetails.rowKey?.substring(0, duplicateRecordDetails.rowKey?.indexOf("|"))}</g:set>
                                            <a href="${collectionsWebappContext}/public/show/${dr}">
                                                ${dataResourceCodes?.get(dr)}
                                            </a>
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.rawScientificName}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Raw Scientific Name">
                                            ${duplicateRecordDetails.rawScientificName}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.latLong}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Coordinates">
                                            ${duplicateRecordDetails.latLong}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.collector}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Collector">
                                            ${duplicateRecordDetails.collector}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.year}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Year">
                                            ${duplicateRecordDetails.year}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.month}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Month">
                                            ${duplicateRecordDetails.month}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <g:if test="${duplicateRecordDetails.day}">
                                        <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Day">
                                            ${duplicateRecordDetails.day}
                                        </alatag:occurrenceTableRow>
                                    </g:if>
                                    <!-- Loop through all the duplicate records -->
                                    <tr class="sectionName">
                                        <td colspan="4">
                                            <g:message code="show.table02.title" />
                                        </td>
                                    </tr>
                                    <g:each in="${duplicateRecordDetails.duplicates}" var="dup">
                                        <g:if test="${dup.uuid}">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Record UUID">
                                                <a href="${request.contextPath}/occurrences/${dup.uuid}">
                                                    ${dup.uuid}
                                                </a>
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.rowKey}">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Data Resource">
                                                <g:set var="dr">${dup.rowKey.substring(0, dup.rowKey.indexOf("|"))}</g:set>
                                                <a href="${collectionsWebappContext}/public/show/${dr}">
                                                    ${dataResourceCodes?.get(dr)}
                                                </a>
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.rawScientificName}">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Raw Scientific Name">
                                                ${dup.rawScientificName}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.latLong}">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Coordinates">
                                                ${dup.latLong}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                         <g:if test="${dup.collector }">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Collector">
                                                ${dup.collector}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.year }">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Year">
                                                ${dup.year}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.month }">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Month">
                                                ${dup.month}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.day }">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Day">
                                                ${dup.day}
                                            </alatag:occurrenceTableRow>
                                        </g:if>
                                        <g:if test="${dup.dupTypes }">
                                            <alatag:occurrenceTableRow annotate="false" section="duplicate" fieldName="Comments">
                                                <g:each in="${dup.dupTypes }" var="dupType">
                                                    <g:if test="${dupType.id }">
                                                        <g:message code="duplication.${dupType.id}" />
                                                        <br />
                                                    </g:if>
                                                </g:each>
                                            </alatag:occurrenceTableRow>
                                            <tr class="sectionName">
                                                <td colspan="4"></td>
                                            </tr>
                                        </g:if>
                                    </g:each>
                                </table>
                            </g:if>
                            </p>
                        </g:if>
                    </div>

                </div>

                <div id="processedVsRawView" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="processedVsRawViewLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                    ×
                                </button>

                                <h3 id="processedVsRawViewLabel">
                                    <g:message code="show.processedvsrawview.title" />
                                </h3>
                            </div>

                            <div class="modal-body">
                                <div class="table-responsive">
                                    <table class="table table-sm table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>
                                                    <g:message code="show.processedvsrawview.table.th01" />
                                                </th>
                                                <th>
                                                    <g:message code="show.processedvsrawview.table.th02" />
                                                </th>
                                                <th>
                                                    <g:message code="show.processedvsrawview.table.th03" />
                                                </th>
                                                <th>
                                                    <g:message code="show.processedvsrawview.table.th04" />
                                                </th>
                                            </tr>
                                        </thead>

                                        <tbody>
                                            <alatag:formatRawVsProcessed map="${compareRecord}" />
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="modal-footer">
                                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true" style="float:right;">
                                    <g:message code="generic.button.close" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </g:if>

            <g:if test="${contacts}">
                <div id="contactCuratorView" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="contactCuratorViewLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                    ×
                                </button>

                                <h3 id="contactCuratorViewLabel">
                                    <g:message code="show.contactcuratorview.title" />
                                </h3>
                            </div>

                            <div class="modal-body">
                                <p>
                                    <g:message code="show.contactcuratorview.message" />
                                </p>

                                <g:each in="${contacts}" var="c">
                                    <address>
                                        <strong>${c.contact.firstName} ${c.contact.lastName} <g:if test="${c.primaryContact}"><span class="primaryContact">*</span></g:if> </strong>

                                        <br />

                                        ${c.role}

                                        <br />

                                        <g:if test="${c.contact.phone}">
                                            <abbr title="Phone">
                                                P:
                                            </abbr>
                                            ${c.contact.phone}
                                            <br />
                                        </g:if>

                                        <g:if test="${c.contact.email}">
                                            <abbr title="Email">E:</abbr>

                                            <alatag:emailLink email="${c.contact.email}">
                                                <g:message code="show.contactcuratorview.emailtext"></g:message>
                                            </alatag:emailLink>

                                            <br />
                                        </g:if>
                                    </address>
                                </g:each>

                                <p>
                                    <span class="primaryContact">
                                        <b>
                                            *
                                        </b>
                                    </span>

                                    <g:message code="show.contactcuratorview.primarycontact" />
                                </p>
                            </div>

                            <div class="modal-footer">
                                <button class="erk-button erk-button--light float-right" data-dismiss="modal" aria-hidden="true">
                                    <g:message code="generic.button.close" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </g:if>

            <ul style="display:none;">
                <li id="userAnnotationTemplate" class="userAnnotationTemplate well">
                    <h3>
                        <span class="issue">
                             - <g:message code="show.userannotationtemplate.title" />
                        </span>
                        <span class="user"></span>
                        <span class="userRole"></span>
                        <span class="userEntity"></span>
                    </h3>

                    <p class="comment"></p>
                    <p class="hide userDisplayName"></p>
                    <p class="created"></p>
                    <p class="viewMore" style="display:none;">
                       <a class="viewMoreLink" href="#">
                           <g:message code="show.userannotationtemplate.p01.navigator" />
                        </a>
                    </p>

                    <br />

                    <p class="deleteAnnotation" style="display:block;">
                        <a class="deleteAnnotationButton erk-button erk-button--light" href="#">
                            <g:message code="show.userannotationtemplate.p02.navigator" />
                        </a>

                        <span class="deleteAssertionSubmitProgress" style="display:none;">
                            <g:img plugin="biocache-hubs" dir="images" file="indicator.gif" alt="indicator icon" />
                        </span>
                    </p>

                    <br/>

                    <div class="container userVerificationClass">
                        <div id="userVerificationTemplate" class="row-fluid userVerificationTemplate" style="display: none">
                            <g:if test="${isCollectionAdmin}">
                                <div class="col-2 qaStatus"></div>
                                <div class="col-4 comment"></div>
                                <div class="col-2 userDisplayName"></div>
                                <div class="col-2 created"></div>
                                <div class="col-2 deleteVerification">
                                    <a class="deleteVerificationButton" style="text-align: right" href="#">
                                        <g:message code="show.userannotationtemplate.p04.navigator" />
                                    </a>
                                </div>
                            </g:if>

                            <g:if test="${!isCollectionAdmin}">
                                <div class="col-2 qaStatus"></div>
                                <div class="col-6 comment"></div>
                                <div class="col-2 userDisplayName"></div>
                                <div class="col-2 created"></div>
                            </g:if>
                        </div>
                    </div>

                    <br/>

                    <g:if test="${isCollectionAdmin}">
                        <p class="verifyAnnotation" style="display:none;">
                            <a class="verifyAnnotationButton erk-button erk-button--light"  href="#verifyRecordModal" data-toggle="modal">
                                <g:message code="show.userannotationtemplate.p03.navigator" />
                            </a>
                        </p>
                    </g:if>
                </li>
            </ul>

            <div id="verifyRecordModal" class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="loginOrFlagLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3>
                                <g:message code="show.verifyrecord.title" />
                            </h3>
                        </div>

                        <div class="modal-body">
                            <div id="verifyAsk">
                                <g:set var="markedAssertions" />
                                <g:if test="!record.processed.geospatiallyKosher">
                                    <g:set var="markedAssertions"><g:message code="show.verifyask.set01" /></g:set>
                                </g:if>

                                <g:if test="!record.processed.taxonomicallyKosher">
                                    <g:set var="markedAssertions">${markedAssertions}${markedAssertions ? ", " : ""}<g:message code="show.verifyask.set02" /></g:set>
                                </g:if>

                                <g:each var="sysAss" in="${record.systemAssertions.failed}">
                                    <g:set var="markedAssertions">${markedAssertions}${markedAssertions ? ", " : ""}<g:message code="${sysAss.name}" /></g:set>
                                </g:each>

                                <p>
                                    <g:message code="show.verifyrecord.p01" /> <b>${markedAssertions}</b>
                                </p>

                                <p style="margin-bottom:10px;">
                                    <g:message code="show.verifyrecord.p02" />
                                </p>

                                <p style="margin-top:20px;">
                                    <label for="userAssertionStatusSelection">
                                        <g:message code="show.verifyrecord.p03" />
                                    </label>

                                    <select name="userAssertionStatusSelection" id="userAssertionStatusSelection">
                                        <option value="50001">
                                            <alatag:message code="user.assertions.50001" />
                                        </option>
                                        <option value="50002">
                                            <alatag:message code="user.assertions.50002" />
                                        </option>
                                        <option value="50003">
                                            <alatag:message code="user.assertions.50003" />
                                        </option>
                                    </select>
                                </p>

                                <p>
                                    <textarea id="verifyComment" rows="3" style="width: 90%"></textarea>
                                </p>

                                <br>

                                <button id="confirmVerify" class="erk-button erk-button--light confirmVerify">
                                    <g:message code="show.verifyrecord.btn.confirmverify" />
                                </button>
                                <button class="erk-button erk-button--light cancelVerify"  data-dismiss="modal">
                                    <g:message code="show.btn.cancel" />
                                </button>
                                <img src="${request.contextPath}/images/spinner.gif" id="verifySpinner" class="verifySpinner hide" alt="spinner icon" />
                            </div>
                        </div>

                        <div class="modal-footer">
                            <div id="verifyDone" style="display:none;">
                                <g:message code="show.verifydone.message" />
                                <br />
                                <button class="erk-button erk-button--light closeVerify" data-dismiss="modal">
                                    <g:message code="show.button.close" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <g:if test="${!record.raw}">
                <div id="headingBar">
                    <h1>
                        <g:message code="show.headingbar02.title" />
                    </h1>
                    <p>
                        <g:message code="show.headingbar02.p01" />
                        "${uuid}"
                        <g:message code="show.headingbar02.p02" />
                    </p>
                </div>
            </g:if>
        </g:if>
        <g:else>
            <h3>
                <g:message code="show.body.error.title" />
                <br />
                ${flash.message}
            </h3>
        </g:else>
    </body>
</html>
