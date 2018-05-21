<div class="modal-dialog modal-lg modal-dialog--wide">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="processedVsRawViewLabel">
                <g:message code="show.processedvsrawview.title" />
            </h3>
        </div>

        <div class="modal-body">
            <div class="table-responsive">
                <table class="table table-sm table-bordered">
                    <thead>
                        <tr>
                            <th style="width:15%">
                                <g:message code="show.processedvsrawview.table.th01" />
                            </th>
                            <th style="width:25%">
                                <g:message code="show.processedvsrawview.table.th02" />
                            </th>
                            <th style="width:30%">
                                <g:message code="show.processedvsrawview.table.th03" />
                            </th>
                            <th style="width:30%">
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
                <g:message code="general.btn.close" />
            </button>
        </div>
    </div>
</div>
