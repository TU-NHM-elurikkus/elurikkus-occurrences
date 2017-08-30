<div class="dropdown-menu search-filter-menu" id="customiseFilters" aria-labelledby="customiseFiltersButton">
    <%-- XXX dropdown-item class --%>
    <h4 class="dropdown-item search-filter-menu--title">
        <g:message code="list.customisefacetsbutton.div01.title" />
    </h4>

    <div class="search-filter-menu--buttons">
        <button id="selectAll" class="erk-link-button">
            <g:message code="list.facetcheckboxes.navigator01" />
        </button>

        &nbsp;|&nbsp;

        <button id="selectNone" class="erk-link-button">
            <g:message code="list.facetcheckboxes.navigator02" />
        </button>

        &nbsp;|&nbsp;

        <button id="updateFacetOptions" class="erk-link-button">
            <g:message code="list.facetcheckboxes.button.updatefacetoptions" />
        </button>

        &nbsp;|&nbsp;

        <button id="resetFacetOptions" class="erk-link-button">
            <g:message code="list.facetcheckboxes.button.resetfacetoptions" />
        </button>
    </div>

    <div class="search-filter-menu--facets">
        <%-- iterate over the groupedFacets, checking the default facets for each entry --%>
        <g:set var="count" value="0" />

        <g:each var="group" in="${groupedFacets}">
            <g:if test="${defaultFacets.find { key, value -> group.value.any { it == key} }}">
                <div class="search-filter-menu--facets--facet"> <%-- TEST --%>
                    <div class="facetGroupName">
                        <g:message code="facet.group.${group.key}" default="${group.key}" />
                    </div>

                    <g:each in="${group.value}" var="fieldValue">
                        <g:if test="${defaultFacets.containsKey(fieldValue)}">
                            <g:set var="count" value="${count + 1}" />

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
