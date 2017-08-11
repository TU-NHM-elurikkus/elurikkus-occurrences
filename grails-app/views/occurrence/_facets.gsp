<div style="clear:both;">
    <g:if test="${sr.query}">
        <g:set var="queryStr" value="${params.q ? params.q : searchRequestParams.q}" />
        <g:set var="paramList" value="" />
        <g:set var="queryParam" value="${sr.urlParameters.stripIndent(1)}" />
    </g:if>

    <g:set var="facetMax" value="${10}" />
    <g:set var="i" value="${1}" />

    <g:each var="group" in="${groupedFacets}">
        <g:set var="keyCamelCase" value="${group.key.replaceAll(/\s+/,'')}" />

        <div class="facetGroupName dropdown-toggle" id="heading_${keyCamelCase}">
            <a href="#" class="showHideFacetGroup" data-name="${keyCamelCase}">
                <g:message code="facet.group.${group.key}" default="${group.key}" />
            </a>
        </div>

        <%-- Starting with display none. TODO: Hide with classes. --%>
        <div id="group_${keyCamelCase}" style="display: none;" class="facetsGroup">
            <g:set var="firstGroup" value="${false}" />

            <g:each in="${group.value}" var="fieldValue">
                <%--  Do a lookup on groupedFacetsMap for the current facet --%>
                <g:set var="facetResult" value="${groupedFacetsMap.get(fieldValue)}" />

                <%-- Tests for when to display a facet --%>
                <g:if test="${facetResult && facetResult.fieldResult.length() >= 1 && facetResult.fieldResult[0].count != sr.totalRecords && ! sr.activeFacetMap?.containsKey(facetResult.fieldName ) }">
                    <g:set var="fieldDisplayName" value="${alatag.formatDynamicFacetName(fieldName: "${facetResult.fieldName}")}" />

                    <div class="FieldName">
                        <%-- These should be marked for translation, but currently load more modal fills that table with
                        JQuery code. That should be refactored to groovy level
                        --%>
                        ${fieldDisplayName}
                    </div>

                    %{-- WIP Removed nano class. --}%
                    <div class="subnavlist" style="clear:left">
                        <alatag:facetLinkList facetResult="${facetResult}" queryParam="${queryParam}" fieldDisplayName="${fieldDisplayName}" />
                    </div>

                    %{--<div class="fadeout"></div>--}%

                    <g:if test="${facetResult.fieldResult.length() > 0}">
                        <div class="showHide">
                            <a id="multi-${facetResult.fieldName}"
                                href="#multipleFacets"
                                class="multipleFacetsLink"
                                role="button"
                                data-toggle="modal"
                                data-displayname="${fieldDisplayName}"
                                title="<g:message code='facets.button.chooseMore.title'/>"
                            >
                                <g:message code="facets.button.chooseMore.label"/>...
                            </a>
                        </div>
                    </g:if>
                </g:if>
            </g:each>
        </div>
    </g:each>

</div>

<!-- modal popup for "choose more" link -->
%{-- XXX Hide doesn't work with Bootstrap 4.--}%
<div id="multipleFacets" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="multipleFacetsLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>

                <h3 id="multipleFacetsLabel">
                    <g:message code="facets.multiplefacets.title"/>
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
                                        <a
                                            href="#count"
                                            class="fsort"
                                            data-sort="count"
                                            data-foffset="0"
                                            title="<g:message code='facets.multiplefacets.tableth01.sort' />"
                                        >
                                            <g:message code="facets.multiplefacets.tableth01"/>
                                        </a>
                                    </th>
                                </tr>
                            </thead>

                            <tbody class="scrollContent">
                                %{-- What is this hiden row for? Though seems like a hack - somewhere it is popped or is it? --}%
                                <tr style="display: none;">
                                    <td>
                                        <input type="checkbox" name="fqs" class="fqs" value="">
                                    </td>
                                    <td>
                                        <a href=""></a>
                                    </td>
                                    <td style="text-align: right; border-right-style: none;">
                                    </td>
                                </tr>
                                <tr id="spinnerRow">
                                    <td colspan="3" style="text-align: center;">
                                        <g:message code="facets.multiplefacets.tabletr01td01"/>...
                                        <g:img plugin="biocache-hubs" dir="images" file="spinner.gif" id="spinner2" class="spinner" alt="spinner icon" />
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
                                <g:message code="facets.submitfacets.li01"/>
                            </a>
                        </li>
                    </ul>
                </div>

                &nbsp;

                <div class="btn-group">
                    <button type="submit" class="submit erk-button erk-button--light" id="exclude">
                        <g:message code="facets.excludeSelected.button"/>
                    </button>

                    <button class="erk-button erk-button--light dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>

                    <ul class="dropdown-menu">
                        <!-- dropdown menu links -->
                        <li>
                            <a href="#" class="dropdown-item wildcard" id="excludeAll">
                                <g:message code="facets.submitfacets.li02"/>
                            </a>
                        </li>
                    </ul>
                </div>

                &nbsp;

                %{-- XXX Hide doesn't work with Bootstrap 4.--}%
                <button id="downloadFacet" class="erk-button erk-button--light" title="${g.message(code:'facets.downloadfacets.button')}">
                    <i class="fa fa-download" title="${g.message(code:'facets.downloadfacets.button')}"></i>

                    <span class="hide">
                        <g:message code="facets.downloadfacets.button"/>
                    </span>
                </button>

                <button class="erk-button erk-button--light" data-dismiss="modal" aria-hidden="true" style="float:right;">
                    <g:message code="generic.button.close" />
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    var dynamicFacets = new Array();

    <g:each in="${dynamicFacets}" var="dynamicFacet">
        dynamicFacets.push('${dynamicFacet.name}');
    </g:each>
</script>
