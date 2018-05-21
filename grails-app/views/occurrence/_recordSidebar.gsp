<g:if test="${isUnderCas && !isReadOnly && record.processed.attribution.provenance != 'Draft'}">
    <%-- XXX --%>
    <div class="sidebar" style="float:left;">
        <%-- Remove it for now. Put it back or delete when we have decided whether or not we need it at all.
        <button
            class="erk-button erk-button--light"
            id="assertionButton"
            href="#loginOrFlag"
            role="button"
            data-toggle="modal"
            title="report a problem or suggest a correction for this record"
        >
            <span id="loginOrFlagSpan" title="Flag an issue" class="">
                <span class="icon-flag"></span>
                <g:message code="show.loginorflag.title" />
            </span>
        </button>
        --%>

        <div id="loginOrFlag" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="loginOrFlagLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 id="loginOrFlagLabel">
                            <g:message code="show.loginorflag.title" />
                        </h3>
                    </div>

                    <div class="modal-body">
                        <g:if test="${!userId}">
                            <div style="margin: 20px 0;">
                                <g:message code="show.loginorflag.label.01" />
                                <a href="${grailsApplication.config.casServerLoginUrl}?service=${serverName}${request.contextPath}/occurrences/${record.raw.uuid}">
                                    <g:message code="show.loginorflag.navigator" />
                                </a>
                            </div>
                        </g:if>

                        <g:else>
                            <div>
                                <%-- XXX --%>
                                <g:message code="show.loginorflag.label.02" />
                                <strong>
                                    ${userDisplayName} (${alatag.loggedInUserEmail()})
                                </strong>

                                <form id="issueForm">
                                    <p style="margin-top:20px;">
                                        <label for="issue">
                                            <g:message code="show.issueform.label.01" />
                                        </label>

                                        <select name="issue" id="issue">
                                            <g:each in="${errorCodes}" var="code">
                                                <option value="${code.code}">
                                                    <g:message code="${code.name}" default="${code.name}" />
                                                </option>
                                            </g:each>
                                        </select>
                                    </p>

                                    <p style="margin-top:30px;">
                                        <label for="issueComment" style="vertical-align:top;">
                                            <g:message code="show.issueform.label.02" />
                                        </label>
                                        <textarea name="comment" id="issueComment" style="width:380px;height:150px;" placeholder="Please add a comment here..."></textarea>
                                    </p>

                                    <p style="margin-top:20px;">
                                        <input
                                            id="issueFormSubmit"
                                            type="submit"
                                            value="<g:message code='show.issueform.button.submit' />"
                                            class="erk-button erk-button--light"
                                        />
                                        <input
                                            type="reset"
                                            value="<g:message code='show.issueform.button.cancel' />"
                                            class="erk-button erk-button--light"
                                            onClick="$('#loginOrFlag').modal('hide');"
                                        />
                                        <input
                                            type="button"
                                            id="close"
                                            value="<g:message code='general.btn.close' />"
                                            class="erk-button erk-button--light"
                                            style="display:none;"
                                        />
                                        <span id="submitSuccess"></span>
                                    </p>

                                    <p id="assertionSubmitProgress" style="display:none;">
                                        <g:img plugin="elurikkus-biocache-hubs" dir="images" file="spinner.gif" alt="indicator icon" />
                                    </p>
                                </form>
                            </div>
                        </g:else>
                    </div>

                    <div class="hide modal-footer">
                        <button
                            class="erk-button erk-button--light"
                            data-dismiss="modal"
                            aria-hidden="true"
                            style="float:right;"
                        >
                            <g:message code="general.btn.close" />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:if>

<div class="sidebar-general-info">
    <div class="sidebar-general-info__item">
        <a href="#userAnnotationsDiv" id="userAnnotationsNav" style="display:none;">
            <g:message code="show.userannotations.title" />
        </a>
    </div>

    <g:if test="${record.processed.occurrence.outlierForLayers}">
        <div class="sidebar-general-info__item">
            <a href="#outlierInformation">
                <g:message code="show.outlierinformation.title" />
            </a>
        </div>
    </g:if>

    <g:if test="${record.processed.occurrence.duplicationStatus}">
        <div class="sidebar-general-info__item">
            <a href="#inferredOccurrenceDetails">
                <g:message code="show.inferredoccurrencedetails.title" />
            </a>
        </div>
    </g:if>
</div>

<g:if test="${false && record.processed.attribution.provenance != 'Draft'}">
    <div class="sidebar">
        <div id="warnings">

            <div id="systemAssertionsContainer" <g:if test="${!record.systemAssertions}">style="display:none"</g:if>>
                <h3>
                    <g:message code="show.systemassertioncontainer.title" />
                </h3>

                <span id="systemAssertions">
                    <li class="failedTestCount">
                        <g:message code="assertions.failed" />: ${record.systemAssertions.failed?.size() ?: 0}
                    </li>
                    <li class="warningsTestCount">
                        <g:message code="assertions.warnings" />: ${record.systemAssertions.warning?.size() ?: 0}
                    </li>
                    <li class="passedTestCount">
                        <g:message code="assertions.passed" />: ${record.systemAssertions.passed?.size() ?: 0}
                    </li>
                    <li class="missingTestCount">
                        <g:message code="assertions.missing" />: ${record.systemAssertions.missing?.size() ?: 0}
                    </li>
                    <li class="uncheckedTestCount">
                        <g:message code="assertions.unchecked" />: ${record.systemAssertions.unchecked?.size() ?: 0}
                    </li>

                    <li id="dataQualityFurtherDetails">
                        <i class="icon-hand-right"></i>&nbsp;
                        <a id="dataQualityReportLink" href="#dataQualityReport">
                            <g:message code="show.dataqualityreportlink.navigator" />
                        </a>
                    </li>

                    <g:set var="hasExpertDistribution" value="${false}" />
                    <g:each var="systemAssertion" in="${record.systemAssertions.failed}">
                        <g:if test="${systemAssertion.code == 26}">
                            <g:set var="hasExpertDistribution" value="${true}" />
                        </g:if>
                    </g:each>

                    <g:set var="isDuplicate" value="${false}" />
                    <g:if test="${record.processed.occurrence.duplicationStatus}">
                        <g:set var="isDuplicate" value="${true}" />
                    </g:if>

                    <g:if test="${isDuplicate}">
                        <li>
                            <i class="icon-hand-right"></i>&nbsp;
                            <a id="duplicateLink" href="#inferredOccurrenceDetails">
                                <g:message code="show.duplicatelink.navigator" />
                            </a>
                        </li>
                    </g:if>

                    <g:if test="${hasExpertDistribution}">
                        <li>
                            <i class="icon-hand-right"></i>&nbsp;
                            <a id="expertRangeLink" href="#expertReport">
                                <g:message code="show.expertrangelink.navigator" />
                            </a>
                        </li>
                    </g:if>

                    <g:if test="${record.processed.occurrence.outlierForLayers}">
                        <li>
                            <i class="icon-hand-right"></i>&nbsp;
                            <a id="outlierReportLink" href="#outlierReport">
                                <g:message code="show.outlierreportlink.navigator" />
                            </a>
                        </li>
                    </g:if>
                </span>

                <!--<p class="half-padding-bottom">Data validation tools identified the following possible issues:</p>-->
                <g:set var="recordIsVerified" value="false" />

                <g:each in="${record.userAssertions}" var="userAssertion">
                    <g:if test="${userAssertion.name == 'userVerified'}">
                        <g:set var="recordIsVerified" value="true" />
                    </g:if>
                </g:each>
            </div>

            <div id="userAssertionsContainer" <g:if test="${!record.userAssertions && !queryAssertions}">style="display:none"</g:if>>
                <h3>
                    <g:message code="show.userassertionscontainer.title" />
                </h3>
                <ul id="userAssertions">
                    <%-- <p class="half-padding-bottom">Users have highlighted the following possible issues:</p> --%>
                    <alatag:groupedAssertions groupedAssertions="${groupedAssertions}" />
                </ul>
                <div id="userAssertionsDetailsLink">
                    <a id="showUserFlaggedIssues" href="#userAnnotations">
                        <g:message code="show.showuserflaggedissues.navigator" />
                    </a>
                </div>
            </div>
        </div>
    </div>
</g:if>

<%-- <g:if test="${isCollectionAdmin && (record.systemAssertions.failed || record.userAssertions) && ! recordIsVerified}">
    <div class="sidebar">
        <button class="erk-button erk-button--light" id="verifyButton" href="#verifyRecord" data-toggle="modal">
            <span id="verifyRecordSpan" title="">
                <g:message code="show.button.verifybtn.span" />
            </span>
        </button>

        <div id="verifyRecord" class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="loginOrFlagLabel" aria-hidden="true">
            <div class="modal-header">
                <h3>
                    <g:message code="show.verifyrecord.title" />
                </h3>
            </div>

            <div class="modal-body">
                <div id="verifyAsk">
                    <g:set var="markedAssertions" />
                    <g:if test="!record.processed.geospatiallyKosher">
                        <g:set var="markedAssertions">
                            <g:message code="show.verifyask.set01" />
                        </g:set>
                    </g:if>
                    <g:if test="!record.processed.taxonomicallyKosher">
                        <g:set var="markedAssertions">${markedAssertions}${markedAssertions ? ", " : ""}
                            <g:message code="show.verifyask.set02" />
                        </g:set>
                    </g:if>
                    <g:each var="sysAss" in="${record.systemAssertions.failed}">
                        <g:set var="markedAssertions">${markedAssertions}${markedAssertions ? ", " : ""}
                            <g:message code="${sysAss.name}" />
                        </g:set>
                    </g:each>
                    <p>
                        <g:message code="show.verifyrecord.p01" />
                        <b>
                            ${markedAssertions}
                        </b>
                    </p>
                    <p style="margin-bottom:10px;">
                        <g:message code="show.verifyrecord.p02" />
                    </p>
                    <p style="margin-top:20px;">
                        <label for="userAssertionStatus">
                            <g:message code="show.verifyrecord.p03" />
                        </label>
                        <select name="userAssertionStatus" id="userAssertionStatus">
                            <g:each in="${verificationCategory}" var="code">
                                <option value="${code}">
                                    <g:message code="${code}" default="${code}" />
                                </option>
                            </g:each>
                        </select>
                    </p>
                    <p>
                        <textarea id="verifyComment" rows="3" style="width: 90%"></textarea>
                    </p>

                    <br />

                    <button
                        class="erk-button erk-button--light confirmVerify">
                        <g:message code="show.verifyrecord.btn.confirmverify" />
                    </button>
                    <button
                        class="erk-button erk-button--light cancelVerify"
                        data-dismiss="modal">
                        <g:message code="general.btn.cancel" />
                    </button>
                    <img src="${request.contextPath}/images/spinner.gif" id="verifySpinner" class="hide" alt="spinner icon" />
                </div>
            </div>
            <div class="modal-footer">
                <div id="verifyDone" style="display:none;">
                    <g:message code="show.verifydone.message" />
                    <br />
                    <button class="erk-button erk-button--light closeVerify" data-dismiss="modal">
                        <g:message code="general.btn.close" />
                    </button>
                </div>
            </div>
        </div>
    </div>
</g:if> --%>

<g:set var="latLngStr">
    <g:if test="${clubView && record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
        ${record.raw.location.decimalLatitude},${record.raw.location.decimalLongitude}
    </g:if>
    <g:elseif test="${record.processed.location.decimalLatitude && record.processed.location.decimalLongitude}">
        ${record.processed.location.decimalLatitude},${record.processed.location.decimalLongitude}
    </g:elseif>
</g:set>

<g:set var="mapCenter">
    <g:if test="${latLngStr.trim()}">
        ${latLngStr.trim()}
    </g:if>
    <g:else>
        ${grailsApplication.config.map.defaultLatitude},${grailsApplication.config.map.defaultLongitude}
    </g:else>
</g:set>

<div class="sidebar">
    <%-- <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script> --%>
    <script type="text/javascript">
        $(document).ready(function() {
            var hasMarker = Boolean(${latLngStr.trim()});
            var markerLatLng = hasMarker ? new google.maps.LatLng(${latLngStr.trim()}) : null;
            var centerLatLng = new google.maps.LatLng(${mapCenter});
            var myOptions = {
                zoom: 6,
                center: centerLatLng,
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

            var map = new google.maps.Map(document.getElementById("occurrenceMap"), myOptions);

            if(hasMarker) {
                var marker = new google.maps.Marker({
                    position: markerLatLng,
                    map: map,
                    title: "${message(code: 'show.occurrencemap.marker')}"
                });
            }

            <g:if test="${record.processed.location.coordinateUncertaintyInMeters}">
                var radius = parseInt('${record.processed.location.coordinateUncertaintyInMeters}');

                if(!isNaN(radius)) {
                    // Add a Circle overlay to the map.
                    circle = new google.maps.Circle({
                        map: map,
                        radius: radius, // 3000 km
                        strokeWeight: 1,
                        strokeColor: 'white',
                        strokeOpacity: 0.5,
                        fillColor: '#2C48A6',
                        fillOpacity: 0.2
                    });
                    // bind circle to marker
                    circle.bindTo('center', marker, 'position');
                }
            </g:if>
        });
    </script>

    <h3>
        <g:message code="show.occurrencemap.title" />
    </h3>

    <div id="occurrenceMap" class="google-maps"></div>
</div>

<g:if test="${record.images}">
    <div class="sidebar">
        <h3 id="images">
            <g:message code="show.sidebar.image.title" />
        </h3>

        <div id="occurrenceImages" class="occurrence-images">
            <g:each in="${record.images}" var="image">
                <div class="occurrence-images__image-container">
                    <%-- data-title is absent on purpose here --%>
                    <a
                        href="${image.alternativeFormats.imageUrl}"
                        data-toggle="lightbox"
                        data-gallery="record-image"
                        data-footer="${
                            render(
                                template: 'recordImageFooter',
                                model: [
                                    'mediaObj': image,
                                    'record': record
                                ]
                            )
                        }"
                        target="_blank"
                    >
                        <img src="${image.alternativeFormats.largeImageUrl}" class="sidebar-media" />
                    </a>
                </div>
            </g:each>
        </div>
    </div>
</g:if>

<g:if test="${record.sounds}">
    <div class="sidebar">
        <h3 id="soundsHeader">
            <g:message code="show.soundsheader.title" />
        </h3>

        <g:each in="${record.sounds}" var="soundObj">
            <div>
                <div>
                    <g:set var="soundURL">
                        ${soundObj.alternativeFormats?.values()?.toArray()[0]}
                    </g:set>

                    <audio controls class="sidebar-media">
                        <source src="${soundURL}">
                        <g:message code="show.soundsheader.notSupported" />
                    </audio>
                </div>

                <g:if test="${soundObj.metadata?.title}">
                    <cite class="sidebar-citation">
                        ${soundObj.metadata?.title}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${soundObj.metadata?.license}">
                    <cite class="sidebar-citation">
                        <g:message code="recordcore.dynamic.license" />: ${soundObj.metadata?.license}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${soundObj.metadata?.rightsHolder}">
                    <cite class="sidebar-citation">
                        <g:message code="recordcore.dynamic.rightsholder" />: ${soundObj.metadata?.rightsHolder}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${soundObj.metadata?.creator}">
                    <cite class="sidebar-citation">
                        <g:message code="media.createdBy.label" />: ${soundObj.metadata?.creator}
                        <br />
                    </cite>
                </g:if>
            </div>
        </g:each>
    </div>
</g:if>

<g:if test="${record.videos}">
    <div class="sidebar">
        <h3>
            <g:message code="show.videosheader.title" />
        </h3>

        <g:each in="${record.videos}" var="videoObj">
            <div>
                <div>
                    <g:set var="videoURL">
                        ${videoObj.alternativeFormats?.values()?.toArray()[0]}
                    </g:set>

                    <video src="${videoURL}" class="sidebar-media" preload="metadata" controls>
                        <g:message code="show.videosheader.notSupported" />
                    </video>
                </div>

                <g:if test="${videoObj.metadata?.title}">
                    <cite class="sidebar-citation">
                        ${videoObj.metadata?.title}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${videoObj.metadata?.license}">
                    <cite class="sidebar-citation">
                        <g:message code="recordcore.dynamic.license" />: ${videoObj.metadata?.license}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${videoObj.metadata?.rightsHolder}">
                    <cite class="sidebar-citation">
                        <g:message code="recordcore.dynamic.rightsholder" />: ${videoObj.metadata?.rightsHolder}
                        <br />
                    </cite>
                </g:if>
                <g:if test="${videoObj.metadata?.creator}">
                    <cite class="sidebar-citation">
                        <g:message code="media.createdBy.label" />: ${videoObj.metadata?.creator}
                        <br />
                    </cite>
                </g:if>
            </div>
        </g:each>
    </div>
</g:if>

<g:if test="${record.raw.lastModifiedTime && record.processed.lastModifiedTime}">
    <%-- XXX --%>
    <div class="sidebar sidebar-citation">
        <g:message code="show.sidebar05.p01" />: ${record.raw.lastModifiedTime.replaceAll("T", " ").replaceAll("Z", "")}
        <br />
        <g:message code="show.sidebar05.p02" />: ${record.processed.lastModifiedTime.replaceAll("T", " ").replaceAll("Z", "")}
    </div>
</g:if>

<%-- XXX This element is hidden, but not removed, for debugging purposes. --%>
<div id="dataQuality" class="additionalData" style="display: none;">
    <a id="dataQualityReport"></a>
    <h3>
        <g:message code="show.dataquality.title" />
    </h3>

    <div id="dataQualityModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-header">
            <h3>
                <g:message code="show.dataqualitymodal.title" />
            </h3>
        </div>

        <div class="modal-body">
            <p>
                <g:message code="show.dataqualitymodal.body" />
                &hellip;
            </p>
        </div>

        <div class="modal-footer">
            <button class="erk-button erk-button--light" data-dismiss="modal">
                <g:message code="general.btn.close" />
            </button>
        </div>
    </div>

    <table class="table table-sm table-bordered data-quality-table">
        <thead>
            <tr class="sectionName">
                <td class="data-quality-test-name">
                    <g:message code="show.tabledataqualityresultscol01.title" />
                </td>

                <td class="data-quality-test-result">
                    <g:message code="show.tabledataqualityresultscol02.title" />
                </td>
            </tr>
        </thead>

        <tbody>
            <%-- failed and warning tests --%>
            <g:set var="failedTestSet" value="${record.systemAssertions.failed}" />
            <g:set var="warningTestSet" value="${record.systemAssertions.warning}" />

            <g:if test="${failedTestSet || warningTestSet}">
                <tr>
                    <td colspan="2">
                        <a
                            id="showErrorAndWarningTests"
                            onclick="toggleTests(this)"
                            href="javascript:void(0)"
                            class="undecorated"
                        >
                            ${failedTestSet ? failedTestSet.length() : 0}
                            <g:message code="show.tabledataqualityresults.tr01td01.fail" />
                            ${warningTestSet ? warningTestSet.length() : 0}
                            <g:message code="show.tabledataqualityresults.tr01td01.warning" />
                            <span class="fa fa-caret-square-o-down"></span>
                        </a>
                    </td>
                </tr>

                <g:each in="${failedTestSet}" var="test">
                    <tr class="failedTestResult">
                        <td class="data-quality-test-name">
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td class="data-quality-test-result">
                            <span class="fa fa-times-circle" style="color:red;"></span>
                            <g:message code="show.tabledataqualityresults.tr01td02" />
                        </td>
                    </tr>
                </g:each>

                <g:each in="${warningTestSet}" var="test">
                    <tr class="warningTestResult">
                        <td class="data-quality-test-name">
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td class="data-quality-test-result">
                            <span class="fa fa-exclamation-circle" style="color:orange;"></span>
                            <g:message code="show.tabledataqualityresults.tr02td02" />
                        </td>
                    </tr>
                </g:each>
            </g:if>

            <%-- passed tests --%>
            <g:set var="passedTestSet" value="${record.systemAssertions.passed}" />

            <g:if test="${passedTestSet}">
                <tr>
                    <td colspan="2">
                        <a
                            id="showPassedTests"
                            onclick="toggleTests(this)"
                            href="javascript:void(0)"
                            class="undecorated"
                        >
                            ${record.systemAssertions.passed.length()}
                            <g:message code="show.tabledataqualityresults.tr03td01" />
                            <span class="fa fa-caret-square-o-down"></span>
                        </a>
                    </td>
                </tr>

                <g:each in="${passedTestSet}" var="test">
                    <tr class="passedTestResult">
                        <td class="data-quality-test-name">
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td class="data-quality-test-result">
                            <span class="fa fa-check-circle" style="color:green;"></span>
                            <g:message code="show.tabledataqualityresults.tr03td02" />
                        </td>
                    </tr>
                </g:each>
            </g:if>

            <%-- missing tests --%>
            <g:if test="${record.systemAssertions.missing}">
                <tr>
                    <td colspan="2">
                        <a
                            id="showMissingPropResult"
                            onclick="toggleTests(this)"
                            href="javascript:void(0)"
                            class="undecorated"
                        >
                            ${record.systemAssertions.missing.length()}
                            <g:message code="show.tabledataqualityresults.tr04td01" />
                            <span class="fa fa-caret-square-o-down"></span>
                        </a>
                    </td>
                </tr>
            </g:if>

            <g:set var="testSet" value="${record.systemAssertions.missing}" />
            <g:each in="${testSet}" var="test">
                <tr class="missingPropResult">
                    <td class="data-quality-test-name">
                        <g:message code="${test.name}" default="${test.name}" />
                        <alatag:dataQualityHelp code="${test.code}" />
                    </td>

                    <td class="data-quality-test-result">
                        <span class="fa fa-question-circle"></span>
                        <g:message code="show.tabledataqualityresults.tr05td02" />
                    </td>
                </tr>
            </g:each>

            <g:if test="${record.systemAssertions.unchecked}">
                <tr>
                    <td colspan="2">
                        <a
                            id="showUncheckedTests"
                            onclick="toggleTests(this)"
                            href="javascript:void(0)"
                            class="undecorated"
                        >
                            ${record.systemAssertions.unchecked.length()}
                            <g:message code="show.tabledataqualityresults.tr06td01" />
                            <span class="fa fa-caret-square-o-down"></span>
                        </a>
                    </td>
                </tr>
            </g:if>

            <g:set var="testSet" value="${record.systemAssertions.unchecked}" />
            <g:each in="${testSet}" var="test">
                <tr class="uncheckTestResult">
                    <td class="data-quality-test-name">
                        <g:message code="${test.name}" default="${test.name}" /><alatag:dataQualityHelp code="${test.code}" />
                    </td>

                    <!--
                        Unchecked results don't use the same styling as checked results,
                        henche no data-quality-test-result class.
                    -->
                    <td>
                        <span class="fa fa-ban"></span>
                        <g:message code="show.tabledataqualityresults.tr07td02" />
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>
</div>
