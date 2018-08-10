<%@ page import="org.apache.commons.lang.StringUtils" %>

<div id="facet-search-container">
    <%-- TEXT SEARCH --%>
    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title01" />
        </legend>

        <label for="text-search">
            <g:message code="advancedsearch.table01col01.title" />
        </label>

        <div>
            <input type="text" id="text-search" class="erk-form-control js-search-input" data-query-param="q" />
        </div>
    </div>

    <%-- TAXA SEARCH --%>
    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title02" />
        </legend>

        <g:each in="${1..4}" var="i">
            <div class="form-group">
                <label for="taxa_${i}">
                    <g:message code="advancedsearch.table02col01.title" />
                </label>

                <div>
                    <input
                        type="text"
                        id="taxa-facet_${i}"
                        class="facet-search erk-form-control js-search-input"
                        placeholder="${message(code: 'advancedsearch.ac.placeholder')}&hellip;"
                        title="${message(code: 'advancedsearch.ac.title')}"
                        data-toggle="tooltip"
                        data-query-param="fq"
                        data-facet-name="taxon_name"
                        value=""
                    />
                </div>
            </div>
        </g:each>
    </div>

    <%-- BASIS OF RECORD --%>
    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title08" />
        </legend>

        <label>
            <g:message code="advancedsearch.table08col01.title" />
        </label>

        <select
            class="basis_of_record erk-form-control js-search-input"
            data-query-param="fq"
            data-facet-name="basis_of_record"
            name="basis_of_record"
            id="basis_of_record"
        >
            <option value="">
                <g:message code="advancedsearch.table08col01.option.label" />
            </option>

            <g:each var="bor" in="${request.getAttribute("basis_of_record")}">
                <option value="${bor.key}">
                    <g:message code="${bor.value}" />
                </option>
            </g:each>
        </select>
    </div>

    <%-- COLLECTION OR INSTITUTION --%>
    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title05" />
        </legend>

        <label>
            <g:message code="advancedsearch.table05col01.title" />
        </label>

        <select
            class="institution_uid collection_uid erk-form-control js-search-input"
            data-query-param="fq"
            data-facet-name="institution_collection"
            name="institution_collection"
            id="institution_collection"
        >
            <option value="">
                <g:message code="advancedsearch.table05col01.option01.label" />
            </option>

            <option value="*">
                <g:message code="advancedsearch.matchAnything" />
            </option>
        </select>
    </div>

    <%-- COUNTRY --%>
    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title06" />
        </legend>

        <label>
            <g:message code="advancedsearch.table06col01.title" />
        </label>

        <select
            class="country erk-form-control js-search-input"
            name="country"
            data-facet-name="country"
            data-query-param="fq"
            id="country"
        >
            <option value="">
                <g:message code="advancedsearch.table06col01.option.label" />
            </option>

            <g:each var="country" in="${request.getAttribute("country")}">
                <option value="${country.key}">
                    <g:message code="${country.value}" default="${country.key}" />
                </option>
            </g:each>
        </select>
    </div>

    <%-- CATALOGUE NUMBER --%>
    <div class="form-group">
        <label>
            <g:message code="advancedsearch.table09col01.title" />
        </label>

        <input
            type="text"
            id="catalogue_number"
            data-facet-name="catalogue_number"
            data-query-param="fq"
            class="dataset erk-form-control js-search-input"
            placeholder=""
            value=""
        />
    </div>

    <%-- OCCURRENCE ID --%>
    <div class="form-group">
        <label>
            <g:message code="advancedsearch.table09col02.title" />
        </label>

        <input
            type="text"
            id="occurrence_id"
            data-facet-name="occurrence_id"
            data-query-param="fq"
            class="dataset erk-form-control js-search-input"
            placeholder=""
            value=""
        />
    </div>

    <div class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title10" />
        </legend>

        <label>
            <g:message code="advancedsearch.table10col01.title" />
        </label>

        <div>
            <input
                type="date"
                id="start-date"
                name="start_date"
                data-facet-name="start_date"
                data-query-param="fq"
                class="occurrence_date erk-form-control js-search-input"
                placeholder=""
                value=""
            />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col01.des" />
            </small>
        </div>
    </div>

    <div class="form-group">
        <label>
            <g:message code="advancedsearch.table10col02.title" />
        </label>

        <div>
            <input
                type="date"
                id="end-date"
                name="end_date"
                class="occurrence_date erk-form-control js-search-input"
                placeholder=""
                value=""
            />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col02.des" />
            </small>
        </div>
    </div>

    <button class="erk-button erk-button--dark" onclick="facetSearch();">
        <span class="fa fa-search"></span>
        <g:message code="advancedsearch.button.submit" />
    </button>

    <button id="clear-search-form" class="erk-button erk-button--light" onclick="clearSearchInputs();">
        <g:message code="advancedsearch.button.clearAll" />
    </button>
</div>
