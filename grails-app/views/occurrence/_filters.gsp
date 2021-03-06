<div class="dropdown-menu search-filter-menu container" id="customiseFilters" aria-labelledby="customiseFiltersButton">
    <%-- XXX dropdown-item class --%>
    <h4 class="search-filter-menu--title">
        <g:message code="list.customisefacetsbutton.div01.title" />
    </h4>

    <div class="search-filter-menu--facets">
        <%-- iterate over the groupedFacets, checking the default facets for each entry --%>
        <g:each var="group" in="${groupedFacets}">
            <g:if test="${defaultFacets.find { key, value -> group.value.any { it == key} }}">
                <div class="search-filter-menu--facets--facet">
                    <div class="facetGroupName">
                        <b>
                            <g:message code="facet.group.${group.key}" default="${group.key}" />
                        </b>
                    </div>

                    <g:each in="${group.value}" var="fieldValue">
                        <g:if test="${defaultFacets.containsKey(fieldValue)}">
                            <div class="search-filter-checkbox">
                                <input
                                    id="${fieldValue}"
                                    type="checkbox"
                                    name="facets"
                                    class="search-filter-checkbox__label__input"
                                    value="${fieldValue}"
                                    ${(defaultFacets.get(fieldValue)) ? "checked=checked" : ""}
                                >
                                <label class="search-filter-checkbox__label" for="${fieldValue}">
                                    ${alatag.formatDynamicFacetName(fieldName: "${fieldValue}")}
                                </label>
                            </div>
                        </g:if>
                    </g:each>
                </div>
            </g:if>
        </g:each>
    </div>

    <div class="search-filter-menu--buttons">
        <button id="selectAll" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.navigator01" />
        </button>
        <button id="selectNone" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.navigator02" />
        </button>
        <button id="resetFacetOptions" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.button.resetfacetoptions" />
        </button>

        <button id="observationFacets" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.button.observation" />
        </button>
        <button id="specimenFacets" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.button.specimen" />
        </button>

        <button id="updateFacetOptions" class="erk-button erk-button--light">
            <g:message code="list.facetcheckboxes.button.updatefacetoptions" />
        </button>
    </div>
</div>
