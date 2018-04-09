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

                                    <th id="indexCol">
                                        <a
                                            href="#index"
                                            class="fsort"
                                            data-sort="index"
                                            data-foffset="0"
                                            title="${message(code: 'general.list.sortBy.label')}"
                                        >
                                        </a>
                                    </th>

                                    <th style="border-right-style: none;text-align: right;">
                                        <%-- TODO translation --%>
                                        <a
                                            href="#count"
                                            class="fsort"
                                            data-sort="count"
                                            data-foffset="0"
                                            title="${message(code: 'facets.multiplefacets.tableth01.sort')}"
                                        >
                                            <%-- TODO translation --%>
                                            <g:message code="facets.multiplefacets.tableth01" />
                                        </a>
                                    </th>
                                </tr>
                            </thead>

                            <tbody class="scrollContent">
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

            <div id="submitFacets" class="modal-footer" style="text-align: left;">
                <div class="btn-group">
                    <button type="submit" class="submit erk-button erk-button--light" id="include">
                        <g:message code="facets.includeSelected.button" />
                    </button>

                    <button class="erk-button erk-button--light dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>

                    <ul class="dropdown-menu">
                        <!-- dropdown menu links -->
                        <li>
                            <a href="#" class="dropdown-item wildcard" id="includeAll">
                                <g:message code="facets.submitfacets.li01" />
                            </a>
                        </li>
                    </ul>
                </div>

                &nbsp;

                <div class="btn-group">
                    <button type="submit" class="submit erk-button erk-button--light" id="exclude">
                        <g:message code="facets.excludeSelected.button" />
                    </button>

                    <button class="erk-button erk-button--light dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>

                    <ul class="dropdown-menu">
                        <!-- dropdown menu links -->
                        <li>
                            <a href="#" class="dropdown-item wildcard" id="excludeAll">
                                <g:message code="facets.submitfacets.li02" />
                            </a>
                        </li>
                    </ul>
                </div>

                &nbsp;

                <%-- XXX Hide doesn't work with Bootstrap 4.--%>
                <button id="downloadFacet" class="erk-button erk-button--light" title="${g.message(code:'facets.downloadfacets.button')}">
                    <span class="fa fa-download" title="${g.message(code:'facets.downloadfacets.button')}"></span>

                    <span class="hide">
                        <g:message code="facets.downloadfacets.button" />
                    </span>
                </button>

                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true" style="float:right;">
                    <g:message code="general.btn.close" />
                </button>
            </div>
        </div>
    </div>
</div>
