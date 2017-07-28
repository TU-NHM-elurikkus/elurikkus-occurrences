<g:set var="startTime" value="${System.currentTimeMillis()}" />

${alatag.logMsg(msg:"Start of facets.gsp - " + startTime)}

<div style="clear:both;">
    <g:if test="${sr.query}">
        <g:set var="queryStr" value="${params.q ? params.q : searchRequestParams.q}" />
        <g:set var="paramList" value="" />
        <g:set var="queryParam" value="${sr.urlParameters.stripIndent(1)}" />
    </g:if>

    ${alatag.logMsg(msg:"Before grouped facets facets.gsp")}

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

            <g:each in="${group.value}" var="facetFromGroup">
                <%--  Do a lookup on groupedFacetsMap for the current facet --%>
                <g:set var="facetResult" value="${groupedFacetsMap.get(facetFromGroup)}" />

                <%-- Tests for when to display a facet --%>
                <g:if test="${facetResult && facetResult.fieldResult.length() >= 1 && facetResult.fieldResult[0].count != sr.totalRecords && ! sr.activeFacetMap?.containsKey(facetResult.fieldName ) }">
                    <g:set var="fieldDisplayName" value="${alatag.formatDynamicFacetName(fieldName:"${facetResult.fieldName}")}" />

                    <div class="FieldName">
                        ${fieldDisplayName?:facetResult.fieldName}
                    </div>

                    %{-- WIP Removed nano class. --}%
                    <div class="subnavlist" style="clear:left">
                        <alatag:facetLinkList facetResult="${facetResult}" queryParam="${queryParam}" />
                    </div>

                    %{--<div class="fadeout"></div>--}%

                    <g:if test="${facetResult.fieldResult.length() > 0}">
                        <div class="showHide">
                            <a id="multi-${facetResult.fieldName}"
                                href="#multipleFacets"
                                class="multipleFacetsLink"
                                role="button" data-toggle="modal"
                                data-displayname="${fieldDisplayName}"
                                title="See more options or refine with multiple values"
                            >
                               <i class="icon-hand-right"></i> <g:message code="facets.facetfromgroup.link"/>...
                            </a>
                        </div>
                    </g:if>
                </g:if>
            </g:each>
        </div>
    </g:each>

    ${alatag.logMsg(msg:"After grouped facets facets.gsp")}
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
                                    <th>&nbsp;</th>
                                    <th id="indexCol" width="80%"><a href="#index" class="fsort" data-sort="index" data-foffset="0"></a></th>
                                    <th style="border-right-style: none;text-align: right;">
                                        <a href="#count" class="fsort" data-sort="count" data-foffset="0" title="Sort by record count">
                                            <g:message code="facets.multiplefacets.tableth01"/>
                                        </a>
                                    </th>
                                </tr>
                            </thead>

                            <tbody class="scrollContent">
                                %{-- XXX Hide doesn't work with Bootstrap 4.--}%
                                <tr class="hide">
                                    <td><input type="checkbox" name="fqs" class="fqs" value=""></td>
                                    <td><a href=""></a></td>
                                    <td style="text-align: right; border-right-style: none;"></td>
                                </tr>
                                <tr id="spinnerRow">
                                    <td colspan="3" style="text-align: center;"><g:message code="facets.multiplefacets.tabletr01td01"/>... <g:img plugin="biocache-hubs" dir="images" file="spinner.gif" id="spinner2" class="spinner" alt="spinner icon"/></td>
                                </tr>
                            </tbody>

                        </table>
                    </form>
                </div>
            </div>

            <div id="submitFacets" class="modal-footer" style="text-align: left;">
                <div class="btn-group">
                    <button type="submit" class="submit erk-button erk-button--light" id="include">
                        <g:message code="facets.includeSelected.button"/>
                    </button>

                    <button class="erk-button erk-button--light dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>

                    <ul class="dropdown-menu">
                        <!-- dropdown menu links -->
                        <li>
                            <a href="#" class="dropdown-item wildcard" id="includeAll"><g:message code="facets.submitfacets.li01"/></a>
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
                            <a href="#" class="dropdown-item wildcard" id="excludeAll"><g:message code="facets.submitfacets.li02"/></a>
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

<g:if test="${params.benchmarks}">
    <g:set var="endTime" value="${System.currentTimeMillis()}" />

    ${alatag.logMsg(msg:"End of facets.gsp - " + endTime + " => " + (endTime - startTime))}

    <div style="color:#ddd;">
        <g:message code="facets.endtime.l"/> = ${(endTime - startTime)} <g:message code="facets.endtime.r" />
    </div>
</g:if>
