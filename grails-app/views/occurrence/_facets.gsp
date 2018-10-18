<div style="clear:both;">
    <g:if test="${sr.query}">
        <g:set var="queryStr" value="${params.q ? params.q : searchRequestParams.q}" />
        <g:set var="paramList" value="" />
        <g:set var="queryParam" value="${sr.urlParameters.stripIndent(1)}&sort=${sort}&dir=${dir}&pageSize=${sr.pageSize}" />
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

                    <%-- WIP Removed nano class. --%>
                    <div class="subnavlist" style="clear:left">
                        <alatag:facetLinkList
                            facetResult="${facetResult}"
                            queryParam="${queryParam}"
                            fieldDisplayName="${fieldDisplayName}"
                        />
                    </div>

                    <%--<div class="fadeout"></div>--%>

                    <g:if test="${facetResult.fieldResult.length() > 0}">
                        <div class="showHide">
                            <a id="multi-${facetResult.fieldName}"
                                href="#multipleFacets"
                                class="multipleFacetsLink"
                                role="button"
                                data-toggle="modal"
                                data-displayname="${fieldDisplayName}"
                                title="<g:message code='facets.button.chooseMore.title' />"
                            >
                                <g:message code="facets.button.chooseMore.label" />&hellip;
                            </a>
                        </div>
                    </g:if>
                </g:if>
            </g:each>
        </div>
    </g:each>
</div>

<g:render template="more-facets-modal" />

<script type="text/javascript">
    var dynamicFacets = new Array();

    <g:each in="${dynamicFacets}" var="dynamicFacet">
        dynamicFacets.push('${dynamicFacet.name}');
    </g:each>
</script>
