<p class="active-filters">
    <%--
        TODO: Something about the semicolon.
    --%>
    <span class="active-filters__title">
        <alatag:message code="search.filters.heading" />
    </span>:

    <g:each var="fq" in="${sr.activeFacetMap}">
        <g:if test="${fq.key}">
            <alatag:currentFilterItem item="${fq}" />
        </g:if>
    </g:each>

    <%-- WKT spatial filter   --%>
    <g:if test="${params.wkt}">
        <g:set var="spatialType" value="${params.wkt =~ /^\w+/}" />

        <span class="active-filters__filter">
            <span class="active-filters__label">
                Spatial filter: ${spatialType[0]}
            </span>

            <a href="${alatag.getQueryStringForWktRemove()}">
                <span class="fa fa-close active-filters__close-button"></span>
            </a>
        </span>
    </g:if>
    <g:elseif test="${params.radius && params.lat && params.lon}">
        <%-- WHAT IS THIS? --%>
        <span class="active-filters__filter">
            <span class="active-filters__label">
                Spatial filter: CIRCLE
            </span>

            <a href="${alatag.getQueryStringForRadiusRemove()}">
                <span class="fa fa-close active-filters__close-button"></span>
            </a>
        </span>
    </g:elseif>

    <g:if test="${sr.activeFacetMap?.size() > 1}">
        <span
            id="clear-filters-btn"
            class="active-filters__clear-all-button"
            data-facet="all"
        >
            <g:message code="list.resultsreturned.button01" />
        </span>
    </g:if>
</p>
