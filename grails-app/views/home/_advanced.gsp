<%@ page import="org.apache.commons.lang.StringUtils" %>

<form
    id="advancedSearchForm"
    name="advancedSearchForm"
    class="container-fluid advanced-search-form"
    action="${request.contextPath}/advancedSearch"
    method="POST"
>
    <input type="text" id="solrQuery" name="q" style="position:absolute;left:-9999px;" value="${params.q}" />
    <input type="hidden" name="nameType" value="${grailsApplication.config.advancedTaxaField?:'matched_name_children'}" />

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title01" />
        </legend>

        <label for="text">
            <g:message code="advancedsearch.table01col01.title" />
        </label>

        <input
            type="text"
            id="text"
            name="text"
            class="dataset erk-form-control"
            placeholder=""
            value="${params.text}"
        />
    </fieldset>

    <fieldset class="form-group">
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
                        id="taxa_${i}"
                        name="taxonText"
                        class="taxon-autocomplete erk-form-control"
                        placeholder="${message(code: 'advancedsearch.ac.placeholder')}&hellip;"
                        title="${message(code: 'advancedsearch.ac.title')}"
                        data-toggle="tooltip"
                        value=""
                    />
                    <input type="hidden" name="lsid" class="lsidInput" id="taxa_${i}_lsid" value="" />
                </div>
            </div>
        </g:each>
    </fieldset>

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title03" />
        </legend>

        <label>
            <g:message code="advancedsearch.table03col01.title" />
        </label>

        <input
            type="text"
            id="raw_taxon_name"
            name="raw_taxon_name"
            class="dataset erk-form-control"
            placeholder=""
            value=""
        />
    </fieldset>

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title04" />
        </legend>

        <label>
            <g:message code="advancedsearch.table04col01.title" />
        </label>

        <select class="species_group erk-form-control" name="species_group" id="species_group">
            <option value="">
                <g:message code="advancedsearch.table04col01.option.label" />
            </option>
            <g:each var="group" in="${request.getAttribute("species_group")}">
                <option value="${group.key}">
                    <g:message code="facet.species_group.${group.value}" default="${message(code: group.value)}" />
                </option>
            </g:each>
        </select>
    </fieldset>

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title05" />
        </legend>

        <label>
            <g:message code="advancedsearch.table05col01.title" />
        </label>

        <select class="institution_uid collection_uid erk-form-control" name="institution_collection" id="institution_collection">
            <option value="">
                <g:message code="advancedsearch.table05col01.option01.label" />
            </option>
            <option value="*">
                <g:message code="advancedsearch.matchAnything" />
            </option>
        </select>
    </fieldset>

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title06" />
        </legend>

        <label>
            <g:message code="advancedsearch.table06col01.title" />
        </label>

        <select class="country erk-form-control" name="country" id="country">
            <option value="">
                <g:message code="advancedsearch.table06col01.option.label" />
            </option>

            <g:each var="country" in="${request.getAttribute("country")}">
                <option value="${country.key}">
                    <g:message code="${country.value}" default="${country.key}" />
                </option>
            </g:each>
        </select>
    </fieldset>

    <g:if test="${request.getAttribute("type_status") && request.getAttribute("type_status").size() > 1}">
        <fieldset class="form-group">
            <legend class="col-form-legend erk-form-legend">
                <span class="fa fa-info-circle"></span>
                <g:message code="advancedsearch.title07" />
            </legend>

            <label>
                <g:message code="advancedsearch.table07col01.title" />
            </label>

            <select class="type_status erk-form-control" name="type_status" id="type_status">
                <option value="">
                    <g:message code="advancedsearch.table07col01.option.label" />
                </option>

                <g:each var="type" in="${request.getAttribute("type_status")}">
                    <option value="${type.key}">
                        ${type.value}
                    </option>
                </g:each>
            </select>
        </fieldset>
    </g:if>

    <g:if test="${request.getAttribute("basis_of_record") && request.getAttribute("basis_of_record").size() > 1}">
        <fieldset class="form-group">
            <legend class="col-form-legend erk-form-legend">
                <span class="fa fa-info-circle"></span>
                <g:message code="advancedsearch.title08" />
            </legend>

            <label>
                <g:message code="advancedsearch.table08col01.title" />
            </label>

            <select class="basis_of_record erk-form-control" name="basis_of_record" id="basis_of_record">
                <option value="">
                    <g:message code="advancedsearch.table08col01.option.label" />
                </option>

                <g:each var="bor" in="${request.getAttribute("basis_of_record")}">
                    <option value="${bor.key}">
                        <g:message code="${bor.value}" />
                    </option>
                </g:each>
            </select>
        </fieldset>
    </g:if>

    <fieldset class="form-group">
        <legend class="col-form-legend erk-form-legend">
            <span class="fa fa-info-circle"></span>
            <g:message code="advancedsearch.title09" />
        </legend>

        <g:if test="${request.getAttribute("data_resource_uid") && request.getAttribute("data_resource_uid").size() > 1}">
            <div class="form-group">
                <label>
                    <g:message code="advancedsearch.dataset.col.label" />
                </label>

                <select class="dataset erk-form-control" name="dataset" id="dataset">
                    <option value="">
                        <g:message code="advancedsearch.dataset.option.label" />
                    </option>
                    <g:each var="region" in="${request.getAttribute("data_resource_uid").sort({it.value})}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </g:if>

        <div class="form-group">
            <label>
                <g:message code="advancedsearch.table09col01.title" />
            </label>

            <input
                type="text"
                id="catalogue_number"
                name="catalogue_number"
                class="dataset erk-form-control"
                placeholder=""
                value=""
            />
        </div>

        <div class="form-group">
            <label>
                <g:message code="advancedsearch.table09col02.title" />
            </label>

            <input
                type="text"
                id="occurrence_id"
                name="occurrence_id"
                class="dataset erk-form-control"
                placeholder=""
                value=""
            />
        </div>
    </fieldset>

    <fieldset class="form-group">
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
                id="startDate"
                name="start_date"
                class="occurrence_date erk-form-control"
                placeholder=""
                value=""
            />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col01.des" />
            </small>
        </div>
    </fieldset>

    <fieldset class="form-group">
        <label>
            <g:message code="advancedsearch.table10col02.title" />
        </label>

        <div>
            <input
                type="date"
                id="endDate"
                name="end_date"
                class="occurrence_date erk-form-control"
                placeholder=""
                value=""
            />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col02.des" />
            </small>
        </div>
    </fieldset>

    <div>
        <button type="submit" class="erk-button erk-button--dark">
            <span class="fa fa-search"></span>
            <g:message code="advancedsearch.button.submit" />
        </button>

        <input
            type="reset"
            value="${message(code: 'advancedsearch.button.clearAll')}"
            id="clearAll"
            class="erk-button erk-button--light"
            onclick="$('input#solrQuery').val(''); $('input.clear_taxon').click(); return true;"
        />
    </div>
</form>
