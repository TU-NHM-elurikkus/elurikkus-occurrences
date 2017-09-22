<!-- modal popup for "choose more" link -->
<div id="multipleFacets" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="multipleFacetsLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="multipleFacetsLabel">
                    <g:message code="facets.multiplefacets.title" />
                </h3>
            </div>

            <div class="modal-body">
                <div id="dynamic" class="tableContainer">
                    <form name="facetRefineForm" id="facetRefineForm" method="GET" action="/occurrences/search/facets">
                        <table class="table table-sm table-bordered table-striped scrollTable" id="fullFacets">
                            <thead class="fixedHeader">
                                <tr class="tableHead">
                                    <th>
                                        &nbsp;
                                    </th>

                                    <th id="indexCol" width="80%">
                                        <a
                                            href="#index"
                                            class="fsort"
                                            data-sort="index"
                                            data-foffset="0"
                                            title="<g:message code='list.table.sortBy.label' />"
                                        </a>
                                    </th>

                                    <th style="border-right-style: none;text-align: right;">
                                        <%-- TODO translation --%>
                                        <a
                                            href="#count"
                                            class="fsort"
                                            data-sort="count"
                                            data-foffset="0"
                                            title="<g:message code='facets.multiplefacets.tableth01.sort' />"
                                        >
                                            <%-- TODO translation --%>
                                            <g:message code="facets.multiplefacets.tableth01" />
                                        </a>
                                    </th>
                                </tr>
                            </thead>

                            <tbody class="scrollContent">
                                <%-- What is this hiden row for? Though seems like a hack - somewhere it is popped or is it? --%>
                                <tr style="display: none;">
                                    <td>
                                        <input type="checkbox" name="fqs" class="fqs" value="" />
                                    </td>

                                    <td>
                                        <a href=""></a>
                                    </td>

                                    <td style="text-align: right; border-right-style: none;"></td>
                                </tr>

                                <tr id="spinnerRow">
                                    <td colspan="3" style="text-align: center;">
                                        <%-- TODO translation --%>
                                        <g:message code="facets.multiplefacets.tabletr01td01" />...
                                        <g:img plugin="elurikkus-biocache-hubs" dir="images" file="spinner.gif" id="spinner2" class="spinner" alt="spinner icon" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
