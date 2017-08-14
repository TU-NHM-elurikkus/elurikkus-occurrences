<p class="activeFilters">
    <%--
        TODO: Something about the semicolon.
    --%>
    <b>
        <alatag:message code="search.filters.heading" />
    </b>:

    <g:each var="fq" in="${sr.activeFacetMap}">
        <g:if test="${fq.key}">
            <g:set var="hasFq" value="${true}" />
            <alatag:currentFilterItem item="${fq}" cssClass="erk-button erk-button--light erk-button--inline" addCloseBtn="${true}" />
        </g:if>
    </g:each>

    <%-- WKT spatial filter   --%>
    <g:if test="${params.wkt}">
        <g:set var="spatialType" value="${params.wkt =~ /^\w+/}" />

        <a href="${alatag.getQueryStringForWktRemove()}">
            <button class="erk-button erk-button--light erk-button--inline">
                Spatial filter: ${spatialType[0]}
                <span class="closeX">
                    ×
                </span>
            </button>
        </a>
    </g:if>

    <g:elseif test="${params.radius && params.lat && params.lon}">
        <%-- WHAT IS THIS? --%>
        <a href="${alatag.getQueryStringForRadiusRemove()}">
            <button class="erk-button erk-button--light erk-button--inline tooltips" title="Click to remove this filter">
                Spatial filter: CIRCLE
                <span class="closeX">
                    ×
                </span>
            </button>
        </a>
    </g:elseif>

    <g:if test="${sr.activeFacetMap?.size() > 1}">
        <button
            id="clear-filters-btn"
            class="erk-button erk-button--light erk-button--inline"
            data-facet="all"
            title="Click to clear all filters"
        >
            <g:message code="list.resultsreturned.button01" />
        </button>
    </g:if>
</p>
