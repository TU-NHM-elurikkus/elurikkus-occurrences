<div class="dropdown-menu search-filter-menu" id="customiseFilters" aria-labelledby="customiseFiltersButton">
    %{-- XXX dropdown-item class --}%
    <h4 class="dropdown-item search-filter-menu--title">
        <g:message code="list.customisefacetsbutton.div01.title" />
    </h4>

    <div class="search-filter-menu--buttons">
        <g:message code="list.facetcheckboxes.label01" />:

        <a href="#" id="selectAll">
            <g:message code="list.facetcheckboxes.navigator01" />
        </a>

        &nbsp;|&nbsp;

        <a href="#" id="selectNone">
            <g:message code="list.facetcheckboxes.navigator02" />
        </a>

        &nbsp;&nbsp;

        <button id="updateFacetOptions" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.button.updatefacetoptions" />
        </button>

        &nbsp;&nbsp;

        <g:set var="resetTitle" value="Restore default settings"/>

        <button id="resetFacetOptions" class="erk-button erk-button--light" title="${resetTitle}">
            <g:message code="list.facetcheckboxes.button.resetfacetoptions" />
        </button>
    </div>

    <div class="search-filter-menu--facets">
        <%-- iterate over the groupedFacets, checking the default facets for each entry --%>
        <g:set var="count" value="0"/>

        <g:each var="group" in="${groupedFacets}">
            <g:if test="${defaultFacets.find { key, value -> group.value.any { it == key} }}">
                <div class="search-filter-menu--facets--facet"> <%-- TEST --%>
                    <div class="facetGroupName">
                        <g:message code="facet.group.${group.key}" default="${group.key}" />
                    </div>

                    <g:each in="${group.value}" var="fieldValue">
                        <g:if test="${defaultFacets.containsKey(fieldValue)}">
                            <g:set var="count" value="${count + 1}"/>

                            <div class="search-filter-checkbox">
                                <label class="search-filter-checkbox__label">
                                    <input
                                        type="checkbox"
                                        name="facets"
                                        class="search-filter-checkbox__label__input"
                                        value="${fieldValue}"
                                        ${(defaultFacets.get(fieldValue)) ? 'checked=checked' : ''}
                                    >
                                    <alatag:message code="facet.${fieldValue}" />
                                </label>
                            </div>
                        </g:if>
                    </g:each>
                </div>
            </g:if>
        </g:each>
    </div>
</div>
