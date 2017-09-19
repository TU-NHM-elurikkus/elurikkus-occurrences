<g:set var="biocacheServiceUrl" value="${alatag.getBiocacheAjaxUrl()}" />

<div id="download" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="downloadsLabel">
                    <g:message code="download.title" />
                </h3>
            </div>

            <div class="modal-body">
                <p>
                    <g:message code="download.terms.01" />
                    <a href="https://plutof.ut.ee/#/privacy-policy" target="_blank">
                        <g:message code="download.terms.02" />
                    </a>
                    <g:message code="download.terms.03" />
                </p>

                <br />

                <p>
                    <g:message code="download.form.title" />
                </p>

                <form id="downloadForm">
                    <input type="hidden" name="searchParams" id="searchParams" value="${sr?.urlParameters}" />
                    <%-- Probs going to be deleted; currently unused anyway
                    <g:if test="${clubView}">
                        <input type="hidden" name="url" id="downloadUrl" value="${request.contextPath}/proxy/download/download" />
                        <input type="hidden" name="url" id="fastDownloadUrl" value="${request.contextPath}/proxy/download/index/download" />
                    </g:if>
                    <g:else>
                        <input type="hidden" name="url" id="downloadUrl" value="${biocacheServiceUrl}/occurrences/download" />
                        <input type="hidden" name="url" id="fastDownloadUrl" value="${biocacheServiceUrl}/occurrences/index/download" />
                    </g:else>
                    --%>
                    <input type="hidden" name="url" id="fastDownloadUrl" value="${biocacheServiceUrl}/occurrences/index/download" />
                    <input type="hidden" name="url" id="downloadChecklistUrl" value="${biocacheServiceUrl}/occurrences/facets/download" />
                    <input type="hidden" name="extra" id="extraFields" value="${grailsApplication.config.biocache.downloads.extra}" />
                    <input type="hidden" name="sourceTypeId" id="sourceTypeId" value="${alatag.getSourceId()}" />

                    <fieldset>
                        <div class="form-group">
                            <label class="col control-label" for="email">
                                <g:message code="download.form.email.label" /> *
                            </label>

                            <div class="col">
                                <input
                                    type="text"
                                    name="email"
                                    id="email"
                                    value="${request.remoteUser}"
                                    class="form-control"
                                />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col control-label" for="filename">
                                <g:message code="download.form.fileName.label" />
                            </label>

                            <div class="col">
                                <input
                                    type="text"
                                    name="filename"
                                    id="filename"
                                    value="${message(code: 'download.form.fileName.value')}"
                                    class="form-control"
                                />
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col control-label" for="reasonTypeId">
                                <g:message code="download.form.reason.label" /> *
                            </label>

                            <div class="col">
                                <select name="reasonTypeId" id="reasonTypeId" class="erk-select">
                                    <option value="">
                                        <g:message code="download.form.reason.placeholder"/>
                                    </option>

                                    <g:each in="${alatag.getLoggerReasons()}" var="reason">
                                        <option value="${reason.key}">
                                            <g:message code="download.form.reason.${reason.key}" default="${reason.value}" />
                                        </option>
                                    </g:each>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col control-label" for="downloadType">
                                <g:message code="download.form.downloadType.label" />
                            </label>

                            <div id="downloadType" class="col">
                                <div>
                                    <label class="erk-radio-label">
                                        <input
                                            type="radio"
                                            name="downloadType"
                                            value="fast"
                                            class="erk-radio-input"
                                            checked="checked"
                                        />
                                        &nbsp;<g:message code="download.form.downloadType.0"/>
                                    </label>
                                </div>
                                <div>
                                    <label class="erk-radio-label">
                                    <input
                                        type="radio"
                                        name="downloadType"
                                        value="checklist"
                                        class="erk-radio-input"
                                    />
                                    &nbsp;<g:message code="download.form.downloadType.1"/>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </form>

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
                    <g:message code="general.btn.close" />
                </button>

                <button id="downloadStart" class="erk-button erk-button--light tooltips">
                    <span class="fa fa-download"></span>
                    <g:message code="general.btn.download.label" />
                </button>
            </div>
        </div>
    </div>
</div>
