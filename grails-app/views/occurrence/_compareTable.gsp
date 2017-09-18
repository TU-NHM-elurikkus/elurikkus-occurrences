<div class="modal-dialog modal-lg modal-dialog--wide">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="processedVsRawViewLabel">
                <g:message code="show.processedvsrawview.title" />
            </h3>

            <button type="button" class="close" data-dismiss="modal" aria-label="${message(code: 'general.btn.close')}">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <div class="modal-body">
            <div class="table-responsive">
                <table class="table table-sm table-bordered">
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
