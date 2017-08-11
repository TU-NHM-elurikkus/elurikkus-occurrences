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
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            ×
                        </button>

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
                                %{-- XXX --}%
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
                                            value="<g:message code='generic.button.close' />"
                                            class="erk-button erk-button--light"
                                            style="display:none;"
                                        />
                                        <span id="submitSuccess"></span>
                                    </p>

                                    <p id="assertionSubmitProgress" style="display:none;">
                                        <g:img plugin="biocache-hubs" dir="images" file="indicator.gif" alt="indicator icon" />
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
                            <g:message code="generic.button.close" />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:if>

<div class="clearfix"></div>

<div class="sidebar-general-info">
    <div class="sidebar-general-info__item">
        <a href="#userAnnotationsDiv" id="userAnnotationsNav" style="display:none;">
            <g:message code="show.userannotations.title" />
        </a>
    </div>

    <g:if test="${record.systemAssertions && record.processed.attribution.provenance != 'Draft'}">
        <div class="sidebar-general-info__item">
            <a href="#dataQuality">
                <g:message code="show.dataquality.title" />
                (${record.systemAssertions.failed?.size()?:0} <i class="fa fa-times-circle tooltips" style="color:red;" title="<g:message code='assertions.failed' />"></i>,
                ${record.systemAssertions.warning?.size()?:0} <i class="fa fa-exclamation-circle tooltips" style="color:orange;" title="<g:message code='assertions.warnings' />"></i>,
                ${record.systemAssertions.passed?.size()?:0} <i class="fa fa-check-circle tooltips" style="color:green;" title="<g:message code='assertions.passed' />"></i>,
                ${record.systemAssertions.missing?.size()?:0} <i class="fa fa-question-circle tooltips" style="color:gray;" title="<g:message code='assertions.missing' />"></i>,
                ${record.systemAssertions.unchecked?.size()?:0} <i class="fa fa-ban tooltips" style="color:gray;" title="<g:message code='assertions.unchecked' />"></i>)
            </a>
        </div>
    </g:if>

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
                        <g:message code="generic.button.cancel" />
                    </button>
                    <img src="${request.contextPath}/images/spinner.gif" id="verifySpinner" class="hide" alt="spinner icon" />
                </div>
            </div>
            <div class="modal-footer">
                <div id="verifyDone" style="display:none;">
                    <g:message code="show.verifydone.message" />
                    <br />
                    <button class="erk-button erk-button--light closeVerify" data-dismiss="modal">
                        <g:message code="generic.button.close" />
                    </button>
                </div>
            </div>
        </div>
    </div>
</g:if> --%>

<g:if test="${record.processed.attribution.provenance && record.processed.attribution.provenance == 'Draft'}">
    <div class="sidebar">
        <p class="grey-bg" style="padding:5px; margin-top:15px; margin-bottom:10px;">
            <g:message code="show.sidebar01.p" />
            <a href="http://volunteer.ala.org.au/">
                <g:message code="show.sidebar01.volunteer.navigator" />
            </a>
        </p>

        <button class="erk-button erk-button--light" id="viewDraftButton" >
            <span id="viewDraftSpan" title="View Draft">
                <g:message code="show.button.viewdraftbutton.label" />
            </span>
        </button>
    </div>
</g:if>
<g:if test="${record.processed.location.decimalLatitude && record.processed.location.decimalLongitude}">
    <g:set var="latLngStr">
        <g:if test="${clubView && record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
            ${record.raw.location.decimalLatitude},${record.raw.location.decimalLongitude}
        </g:if>
        <g:else>
            ${record.processed.location.decimalLatitude},${record.processed.location.decimalLongitude}
        </g:else>
    </g:set>
    <div class="sidebar">

        <%-- <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script> --%>
        <script type="text/javascript">
            $(document).ready(function() {
                var latlng = new google.maps.LatLng(${latLngStr.trim()});
                var myOptions = {
                    zoom: 5,
                    center: latlng,
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

                var marker = new google.maps.Marker({
                    position: latlng,
                    map: map,
                    title:"Occurrence Location"
                });

                <g:if test="${record.processed.location.coordinateUncertaintyInMeters}">
                var radius = parseInt('${record.processed.location.coordinateUncertaintyInMeters}');
                if (!isNaN(radius)) {
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

        <h2>
            <g:message code="show.occurrencemap.title" />
        </h2>

        <div id="occurrenceMap" class="google-maps"></div>
    </div>
</g:if>

<g:if test="${record.images}">
    <div class="sidebar">
        <h2 id="images">
            <g:message code="show.sidebar.image.title" />
        </h2>

        <div id="occurrenceImages" style="margin-top:5px;">
            <g:each in="${record.images}" var="image">
                <div style="margin-bottom:10px;">
                    <g:if test="${grailsApplication.config.skin.useAlaImageService.toBoolean()}">
                        <a href="${grailsApplication.config.images.viewerUrl}${image.filePath}" target="_blank">
                            <img
                                src="${image.alternativeFormats.smallImageUrl}"
                                style="max-width: 100%;"
                                alt="Click to view this image in a large viewer"
                            />
                        </a>
                    </g:if>
                    <g:else>
                        <a href="${image.alternativeFormats.largeImageUrl}" target="_blank">
                            <img src="${image.alternativeFormats.smallImageUrl}" style="max-width: 100%;" />
                        </a>
                    </g:else>
                    <br />
                    <g:if test="${record.raw.occurrence.photographer || image.metadata?.creator}">
                        <cite>
                            <g:message code="show.sidebar.image.creator" />: ${record.raw.occurrence.photographer ?: image.metadata?.creator}
                        </cite>
                        <br />
                    </g:if>
                    <g:if test="${record.raw.occurrence.rights || image.metadata?.rights}">
                        <cite>
                            <g:message code="recordcore.dataset.rights" />: ${record.raw.occurrence.rights ?: image.metadata?.rights}
                        </cite>
                        <br />
                    </g:if>
                    <g:if test="${record.raw.occurrence.rightsholder || image.metadata?.rightsholder}">
                        <cite>
                            <g:message code="recordcore.dynamic.rightsholder" />: ${record.raw.occurrence.rightsholder ?: image.metadata?.rightsholder}
                        </cite>
                        <br />
                    </g:if>
                    <g:if test="${record.raw.miscProperties.rightsHolder}">
                        <cite>
                            <g:message code="recordcore.dynamic.rightsholder" />: ${record.raw.miscProperties.rightsHolder}
                        </cite>
                        <br />
                    </g:if>
                    <g:if test="${image.metadata?.license}">
                        <cite>
                            <g:message code="recordcore.dynamic.license" />: ${image.metadata?.license}
                        </cite>
                        <br />
                    </g:if>
                    <g:if test="${grailsApplication.config.skin.useAlaImageService.toBoolean()}">
                        <a href="${grailsApplication.config.images.metadataUrl}${image.filePath}" target="_blank">
                            <g:message code="show.sidebar.occurrenceimages.navigator01" />
                        </a>
                    </g:if>
                    <g:else>
                        <a href="${image.alternativeFormats.imageUrl}" target="_blank">
                            <g:message code="show.sidebar.occurrenceimages.navigator02" />
                        </a>
                    </g:else>
                </div>
            </g:each>
        </div>
    </div>
</g:if>
<g:if test="${record.sounds}">
    <div class="sidebar">
        <h3 id="soundsHeader" style="margin: 20px 0 0 0;">
            <g:message code="show.soundsheader.title" />
        </h3>
        <div>
            <g:set var="soundURLFormats" value="${record.sounds.get(0)?.alternativeFormats}" />
            <g:set var="soundURL">
                <g:if test="${soundURLFormats?.'audio/mpeg'}">
                    ${soundURLFormats.'audio/mpeg'}
                </g:if>
                <g:else>
                    ${soundURLFormats?.values()?.toArray()[0]}
                </g:else>
            </g:set>

            <audio controls class="audio-player">
                <source src="${soundURL}">
                <g:message code="show.soundsheader.notSupported" />
            </audio>
        </div>

        <g:if test="${record.raw.occurrence.rights}">
            <br />
            <cite>
                <g:message code="recordcore.dataset.rights" />: ${record.raw.occurrence.rights}
            </cite>
        </g:if>
    </div>
</g:if>

<g:if test="${record.raw.lastModifiedTime && record.processed.lastModifiedTime}">
    %{-- XXX --}%
    <div class="sidebar" style="margin-top: 10px;font-size: 12px; color: #555;">
        <g:set var="rawLastModifiedString" value="${record.raw.lastModifiedTime.substring(0,10)}" />
        <g:set var="processedLastModifiedString" value="${record.processed.lastModifiedTime.substring(0,10)}" />

        %{-- XXX --}%
        <p style="margin-bottom:20px;">
            <g:message code="show.sidebar05.p01" />: ${rawLastModifiedString}
            <br />
            <g:message code="show.sidebar05.p02" />: ${processedLastModifiedString}
            <br />
        </p>
    </div>
</g:if>

<div id="dataQuality" class="additionalData">
    <a name="dataQualityReport"></a>
    <h2>
        <g:message code="show.dataquality.title" />
    </h2>

    <div id="dataQualityModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">
                ×
            </button>
            <h3>
                <g:message code="show.dataqualitymodal.title" />
            </h3>
        </div>

        <div class="modal-body">
            <p>
                <g:message code="show.dataqualitymodal.body" />
                ...
            </p>
        </div>

        <div class="modal-footer">
            <button class="erk-button erk-button--light" data-dismiss="modal">
                <g:message code="generic.button.close" />
            </button>
        </div>
    </div>

    <table class="table table-sm table-striped table-bordered">
        <thead>
            <tr class="sectionName">
                <td class="dataQualityTestName">
                    <g:message code="show.tabledataqualityresultscol01.title" />
                </td>
                <td class="dataQualityTestResult">
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
                        <a href="javascript:void(0)" id="showErrorAndWarningTests">
                            <g:message code="show.tabledataqualityresults.showhide" />
                            ${failedTestSet ? failedTestSet.length() : 0} <g:message code="show.tabledataqualityresults.tr01td01.fail" />
                            ${warningTestSet ? warningTestSet.length() : 0} <g:message code="show.tabledataqualityresults.tr01td01.warning" />
                        </a>
                    </td>
                </tr>

                <g:each in="${failedTestSet}" var="test">
                    <tr class="failedTestResult">
                        <td>
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td>
                            <span class="fa fa-times-circle" style="color:red;"></span>
                            <g:message code="show.tabledataqualityresults.tr01td02" />
                        </td>
                    </tr>
                </g:each>

                <g:each in="${warningTestSet}" var="test">
                    <tr class="warningTestResult">
                        <td>
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td>
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
                        <a href="javascript:void(0)" id="showPassedTests">
                            <g:message code="show.tabledataqualityresults.showhide" /> ${record.systemAssertions.passed.length()} <g:message code="show.tabledataqualityresults.tr03td01" />
                        </a>
                    </td>
                </tr>

                <g:each in="${passedTestSet}" var="test">
                    <tr class="passedTestResult" style="display:none">
                        <td>
                            <g:message code="${test.name}" default="${test.name}" />
                            <alatag:dataQualityHelp code="${test.code}" />
                        </td>

                        <td>
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
                        <a href="javascript:void(0)" id="showMissingPropResult">
                            <g:message code="show.tabledataqualityresults.showhide" /> ${record.systemAssertions.missing.length()} <g:message code="show.tabledataqualityresults.tr04td01" />
                        </a>
                    </td>
                </tr>
            </g:if>

            <g:set var="testSet" value="${record.systemAssertions.missing}" />
            <g:each in="${testSet}" var="test">
            <tr class="missingPropResult" style="display:none;">
                <td>
                    <g:message code="${test.name}" default="${test.name}" />
                    <alatag:dataQualityHelp code="${test.code}" />
                </td>
                <td>
                    <i class="fa fa-question-circle" />
                    <g:message code="show.tabledataqualityresults.tr05td02" />
                </td>
            </tr>
            </g:each>

            <g:if test="${record.systemAssertions.unchecked}">
                <tr>
                    <td colspan="2">
                        <a href="javascript:void(0)" id="showUncheckedTests">
                            <g:message code="show.tabledataqualityresults.showhide" /> ${record.systemAssertions.unchecked.length()} <g:message code="show.tabledataqualityresults.tr06td01" />
                        </a>
                    </td>
                </tr>
            </g:if>

            <g:set var="testSet" value="${record.systemAssertions.unchecked}" />
            <g:each in="${testSet}" var="test">
            <tr class="uncheckTestResult" style="display:none;">
                <td>
                    <g:message code="${test.name}" default="${test.name}" /><alatag:dataQualityHelp code="${test.code}" />
                </td>
                <td>
                    <i class="fa fa-ban" />
                    <g:message code="show.tabledataqualityresults.tr07td02" />
                </td>
            </tr>
            </g:each>
        </tbody>
    </table>
</div>
