<g:set var="biocacheServiceUrl" value="${alatag.getBiocacheAjaxUrl()}" />

<div id="download" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="downloadsLabel">
                    <g:message code="download.download.title" />
                </h3>
            </div>

            <div class="modal-body">
                <p id="termsOfUseDownload">
                    <g:message code="download.termsofusedownload.01" />
                    <a href="https://plutof.ut.ee/#/privacy-policy" target="_blank">
                        <g:message code="download.termsofusedownload.02" />
                    </a>
                    <g:message code="download.termsofusedownload.03" />
                    <br />
                    <br />
                    <g:message code="download.termsofusedownload.04" />:
                </p>

                <form id="downloadForm">
                    <input type="hidden" name="searchParams" id="searchParams" value="${sr?.urlParameters}" />
                    <g:if test="${clubView}">
                        <input type="hidden" name="url" id="downloadUrl" value="${request.contextPath}/proxy/download/download" />
                        <input type="hidden" name="url" id="fastDownloadUrl" value="${request.contextPath}/proxy/download/index/download" />
                    </g:if>
                    <g:else>
                        <input type="hidden" name="url" id="downloadUrl" value="${biocacheServiceUrl}/occurrences/download" />
                        <input type="hidden" name="url" id="fastDownloadUrl" value="${biocacheServiceUrl}/occurrences/index/download" />
                    </g:else>

                    <input type="hidden" name="url" id="downloadChecklistUrl" value="${biocacheServiceUrl}/occurrences/facets/download" />
                    <input type="hidden" name="extra" id="extraFields" value="${grailsApplication.config.biocache.downloads.extra}" />
                    <input type="hidden" name="sourceTypeId" id="sourceTypeId" value="${alatag.getSourceId()}" />

                    <fieldset>
                        <div class="form-group">
                            <label for="email">
                                <g:message code="download.downloadform.label01" />
                            </label>
                            <input
                                type="text"
                                name="email"
                                id="email"
                                value="${request.remoteUser}"
                                class="form-control"
                            />
                        </div>

                        <div class="form-group">
                            <label for="filename">
                                <g:message code="download.downloadform.label02" />
                            </label>
                            <input
                                type="text"
                                name="filename"
                                id="filename"
                                value="${message(code: 'download.downloadform.fileName')}"
                                class="form-control"
                            />
                        </div>

                        <div class="form-group">
                            <label for="reasonTypeId" style="vertical-align: top">
                                <g:message code="download.downloadform.label03" /> *
                            </label>
                            <select name="reasonTypeId" id="reasonTypeId" class="form-control">
                                <option value="">
                                    -- <g:message code="download.downloadformreasontypeid.option" /> --
                                </option>
                                <g:each var="it" in="${alatag.getLoggerReasons()}">
                                    <option value="${it.id}">
                                        <g:message code="${it.rkey}" />
                                    </option>
                                </g:each>
                            </select>
                        </div>

                        <div>
                            <label for="filename">
                                <g:message code="download.downloadform.downloadType.label" />
                            </label>
                            <br />

                            <div style="padding-left: 5px;">
                                <input
                                    type="radio"
                                    name="downloadType"
                                    value="fast"
                                    class="tooltips"
                                    title="${message(code: 'download.downloadform.downloadType.option.allRecords.title')}"
                                    checked="checked"
                                />

                                <span>
                                    <g:message code="download.downloadform.downloadType.option.allRecords.label" />
                                </span>
                                <br />

                                <input
                                    type="radio"
                                    name="downloadType"
                                    value="checklist"
                                    class="tooltips"
                                    title="${message(code: 'download.downloadform.downloadType.option.speciesChecklist.title')}"
                                />

                                <span>
                                    <g:message code="download.downloadform.downloadType.option.speciesChecklist.label" />
                                </span>
                            </div>
                        </div>
                    </fieldset>
                </form>

                <style type="text/css">
                    /* style outside of HEAD is not valid HTML but is 100% compatible with all modern browsers
                       Why did you put it here then?
                    */
                    #downloadForm fieldset > div {
                        padding: 5px 0;
                    }
                </style>

                <script type="text/javascript">
                    $(document).ready(function() {
                        // catch download submit button
                        // Note the unbind().bind() syntax - due to Jquery ready being inside <body> tag.

                        // start download button
                        $(":input#downloadStart").unbind("click").bind("click", function(e) {
                            e.preventDefault();
                            var downloadType = $('input:radio[name=downloadType]:checked').val();
                            var fileName = $("#filename").val();
                            if (!fileName) {
                                fileName = "${message(code: 'download.downloadform.fileName')}";
                            }

                            if (validateForm()) {
                                if (downloadType == "fast") {
                                    var downloadUrl = generateDownloadPrefix($(":input#fastDownloadUrl").val()) +
                                        "&email=" + $("#email").val() +
                                        "&sourceTypeId=" + $("#sourceTypeId").val() +
                                        "&reasonTypeId=" + $("#reasonTypeId").val() +
                                        "&file=" + fileName +
                                        "&extra=" + $(":input#extraFields").val();
                                    window.location.href = downloadUrl;
                                    notifyDownloadStarted();
                                } else if (downloadType == "checklist") {
                                    var downloadUrl = generateDownloadPrefix($("input#downloadChecklistUrl").val()) +
                                        "&facets=species_guid" +
                                        "&lookup=true" +
                                        "&file=" + fileName +
                                        "&sourceTypeId=" + $("#sourceTypeId").val() +
                                        "&reasonTypeId=" + $("#reasonTypeId").val();
                                    window.location.href = downloadUrl;
                                    notifyDownloadStarted();
                                } else {
                                    // can't happen as type is a fixed list
                                    alert("${message(code:'download.downloadform.downloadType.option.invalid')}");
                                }
                            }
                        });
                    });

                    function generateDownloadPrefix(downloadUrlPrefix) {
                        downloadUrlPrefix = downloadUrlPrefix.replace(/\\ /g, " ");
                        var searchParams = $(":input#searchParams").val();
                        if (searchParams) {
                            downloadUrlPrefix += searchParams;
                        } else {
                            // EYA page is JS driven
                            downloadUrlPrefix += "?q=*:*&" +
                                "lat=" + $('#latitude').val() +
                                "&lon=" + $('#longitude').val() +
                                "&radius=" + $('#radius').val();
                            if (eyaState.speciesGroup && eyaState.speciesGroup != "ALL_SPECIES") {
                                downloadUrlPrefix += "&fq=species_group:" + eyaState.speciesGroup;
                            }
                        }

                        return downloadUrlPrefix;
                    }

                    function notifyDownloadStarted() {
                        window.setTimeout(function() {
                            $('#download').modal('hide');
                        }, 500);
                    }

                    function validateForm() {
                        var isValid = true;
                        var reasonId = $("#reasonTypeId option:selected").val();

                        if (!reasonId) {
                            isValid = false;
                            $("#reasonTypeId").focus();
                            $("label[for='reasonTypeId']").css("color", "red");
                        } else {
                            $("label[for='reasonTypeId']").css("color", "inherit");
                        }

                        return isValid;
                    }

                </script>
            </div>

            <div class="modal-footer">
                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true">
                    <g:message code="generic.button.close" />
                </button>

                <button id="downloadStart" class="erk-button erk-button--light tooltips">
                    <span class="fa fa-download"></span>
                    <g:message code="download.download.label" />
                </button>
            </div>
        </div>
    </div>
</div>
