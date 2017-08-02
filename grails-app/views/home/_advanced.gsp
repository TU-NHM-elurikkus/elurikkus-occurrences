<%@ page import="au.org.ala.biocache.hubs.FacetsName; org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:render template="/layouts/global" plugin="biocache-hubs" />
<form name="advancedSearchForm" id="advancedSearchForm" action="${request.contextPath}/advancedSearch" method="POST" class="container-fluid">
    <input type="text" id="solrQuery" name="q" style="position:absolute;left:-9999px;" value="${params.q}" />
    <input type="hidden" name="nameType" value="${grailsApplication.config.advancedTaxaField?:'matched_name_children'}" />

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title01" />
        </legend>

        <label for="text" class="col-2">
            <g:message code="advancedsearch.table01col01.title"/>
        </label>

        <div class="col-10">
            <input type="text" name="text" id="text" class="dataset form-control" placeholder="" size="80" value="${params.text}" />
        </div>
    </div>

    %{-- XXX row classes --}%
    <fieldset class="form-group">
        <legend class="col-form-legend row">
            <g:message code="advancedsearch.title02" />
        </legend>

        <g:each in="${1..4}" var="i">
            <g:set var="lsidParam" value="lsid_${i}" />
            <div class="form-group row">
                <label for="taxa_${i}" class="col-2">
                    <g:message code="advancedsearch.table02col01.title" />
                    <g:set var="lsidParam" value="lsid_${i}" />
                </label>

                <div class="col-10">
                    <input type="text" value="" id="taxa_${i}" name="taxonText" class="name_autocomplete form-control" size="60">
                    <input type="hidden" name="lsid" class="lsidInput" id="taxa_${i}" value="" />
                </div>
            </div>
        </g:each>
    </fieldset>

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title03" />
        </legend>

        <label class="col-2">
            <g:message code="advancedsearch.table03col01.title" />
        </label>

        <div class="col-10">
            <input type="text" name="raw_taxon_name" id="raw_taxon_name" class="dataset form-control" placeholder="" size="60" value="" />
        </div>
    </div>

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title04" />
        </legend>

        <label class="col-2">
            <g:message code="advancedsearch.table04col01.title" />
        </label>

        <%-- TODO: Classes. --%>
        <div class="col-10">
            <select class="species_group" name="species_group" id="species_group">
                <option value=""><g:message code="advancedsearch.table04col01.option.label" /></option>
                <g:each var="group" in="${request.getAttribute("species_group")}">
                    <option value="${group.key}">
                        <g:message code="${group.key}" />
                    </option>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title05" />
        </legend>

        <label class="col-2">
            <g:message code="advancedsearch.table05col01.title" />
        </label>

        <div class="col-10">
            <select class="institution_uid collection_uid" name="institution_collection" id="institution_collection">
                <option value="">
                    <g:message code="advancedsearch.table05col01.option01.label" />
                </option>

                <%-- ToDo: This select should be dynamic --%>
                <g:each var="inst" in="${request.getAttribute("institution_uid")}">
                    <g:if test="${StringUtils.startsWith(inst.key, 'in')}">
                        <optgroup label="${inst.value}">
                            <option value="${inst.key}">
                                <g:message code="advancedsearch.table05col01.option02.label" />
                            </option>

                            <g:each var="coll" in="${request.getAttribute("collection_uid")}">
                                <g:if test="${inst.key == 'in4' && StringUtils.startsWith(coll.value, 'TAM')}">
                                    <option value="${coll.key}">
                                        ${coll.value}
                                    </option>
                                </g:if>

                                <g:elseif test="${inst.key == 'in5' && coll.value == 'TALL'}">
                                    <option value="${coll.key}">
                                        ${coll.value}
                                    </option>
                                </g:elseif>

                                <g:elseif test="${inst.key == 'in6' && (coll.value == 'EAA' || coll.value == 'TAAM')}">
                                    <option value="${coll.key}">
                                        ${coll.value}
                                    </option>
                                </g:elseif>

                                <g:elseif test="${inst.key == 'in7' && StringUtils.startsWith(coll.value, 'TU')}">
                                    <option value="${coll.key}">
                                        ${coll.value}
                                    </option>
                                </g:elseif>

                            </g:each>
                        </optgroup>
                    </g:if>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title06" /></b>
        </legend>

        <label class="col-2">
            <g:message code="advancedsearch.table06col01.title" />
        </label>

        <div class="col-10">
            <select class="country" name="country" id="country">
                <option value="">
                    <g:message code="advancedsearch.table06col01.option.label" />
                </option>

                <g:each var="country" in="${request.getAttribute("country")}">
                    <option value="${country.key}">
                        ${country.value}
                    </option>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group row">
        <%-- Not sure what is going on here. --%>
        <%-- TODO: Paragraphs for the following section. --%>
        <g:set var="autoPlaceholder" value="start typing and select from the autocomplete drop-down list" />

        <g:if test="${request.getAttribute("cl1048") && request.getAttribute("cl1048").size() > 1}">
            <label class="col-2">
                <abbr title="Interim Biogeographic Regionalisation of Australia">
                    IBRA
                </abbr>
                <g:message code="advancedsearch.table06col03.title" />
            </label>

            <div class="col-10">
                <select class="biogeographic_region form-control" name="ibra" id="ibra">
                    <option value="">
                        <g:message code="advancedsearch.table06col03.option.label" />
                    </option>

                    <g:each var="region" in="${request.getAttribute("cl1048").sort()}">
                        <option value="${region.key}">
                            ${region.value}
                        </option>
                    </g:each>
                </select>
            </div>
        </g:if>
    </div>

    <g:if test="${request.getAttribute("cl21") && request.getAttribute("cl21").size() > 1}">
        <div class="form-group row">
            <label class="col-2">
                <abbr title="Integrated Marine and Coastal Regionalisation of Australia">
                    IMCRA
                </abbr>
                <g:message code="advancedsearch.table06col04.title" />
            </label>

            <div class="col-10">
                <select class="biogeographic_region form-control" name="imcra" id="imcra">
                    <option value="">
                        <g:message code="advancedsearch.table06col04.option.label" />
                    </option>

                    <g:each var="region" in="${request.getAttribute("cl21").sort()}">
                        <option value="${region.key}">
                            ${region.value}
                        </option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("cl959") && request.getAttribute("cl959").size() > 1}">
        <div class="form-group row">
            <label class="col-2">
                <g:message code="advancedsearch.table06col05.title" />
            </label>

            <div class="col-10">
                <select class="lga form-control" name="lga" id="lga">
                    <option value=""><g:message code="advancedsearch.table06col05.option.label" /></option>
                    <g:each var="region" in="${request.getAttribute("cl959").sort()}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("type_status") && request.getAttribute("type_status").size() > 1}">
        <div class="form-group row">
            <legend class="col-form-legend">
                <g:message code="advancedsearch.title07" />
            </legend>

            <label class="col-2">
                <g:message code="advancedsearch.table07col01.title" />
            </label>

            <select class="type_status" name="type_status" id="type_status">
                <option value="">
                    <g:message code="advancedsearch.table07col01.option.label" />
                </option>

                <g:each var="type" in="${request.getAttribute("type_status")}">
                    <option value="${type.key}">
                        ${type.value}
                    </option>
                </g:each>
            </select>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("basis_of_record") && request.getAttribute("basis_of_record").size() > 1}">
        <div class="from-group row">
            <legend class="col-form-legend">
                <g:message code="advancedsearch.title08" />
            </legend>

            <label class="col-2">
                <g:message code="advancedsearch.table08col01.title" />
            </label>

            <div class="col-10">
                <select class="basis_of_record" name="basis_of_record" id="basis_of_record">
                    <option value="">
                        <g:message code="advancedsearch.table08col01.option.label" />
                    </option>

                    <g:each var="bor" in="${request.getAttribute("basis_of_record")}">
                        <option value="${bor.key}">
                            <g:message code="basisOfRecord.${bor.key}" default=""/>
                        </option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>

    <fieldset class="from-group">
        <legend class="col-form-legend row">
            <g:message code="advancedsearch.title09"/>
        </legend>

        <g:if test="${request.getAttribute("data_resource_uid") && request.getAttribute("data_resource_uid").size() > 1}">
            <div class="form-group row">
                <label class="col-2">
                    <g:message code="advancedsearch.dataset.col.label" />
                </label>

                <select class="dataset bscombobox" name="dataset" id="dataset">
                    <option value=""></option>
                    <g:each var="region" in="${request.getAttribute("data_resource_uid").sort({it.value})}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </g:if>

        <div class="form-group row">
            <label class="col-2">
                <g:message code="advancedsearch.table09col01.title" />
            </label/>

            <div class="col-10">
                <input type="text" name="catalogue_number" id="catalogue_number" class="dataset form-control" placeholder="" value="" />
            </div>
        </div>

        <div class="form-group row">
            <label class="col-2">
                <g:message code="advancedsearch.table09col02.title" />
            </label>

            <div class="col-10">
                <input type="text" name="record_number" id="record_number" class="dataset form-control" placeholder="" value="" />
            </div>
        </dig>
    </fieldset>

    <div class="form-group row">
        <legend class="col-form-legend">
            <g:message code="advancedsearch.title10" />
        </legend>

        <label class="col-2">
            <g:message code="advancedsearch.table10col01.title" />
        </label>

        <div class="col-10">
            <input type="text" name="start_date" id="startDate" class="occurrence_date form-control" placeholder="" value="" />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col01.des" />
            </small>
        </div>
    </div>

    <div class="form-group row">
        <label class="col-2">
            <g:message code="advancedsearch.table10col02.title" />
        </label>

        <div class="col-10">
            <input type="text" name="end_date" id="endDate" class="occurrence_date form-control" placeholder="" value="" />
            <small class="form-text text-muted">
                <g:message code="advancedsearch.table10col02.des" />
            </small>
        </div>
    </div>

    <div class="row">
        <input
            type="submit"
            value="<g:message code="advancedsearch.button.submit" />"
            class="erk-button erk-button--light" />
        &nbsp;&nbsp;
        <input
            type="reset"
            value="<g:message code="advancedsearch.button.clearAll"/>"
            id="clearAll"
            class="erk-button erk-button--light"
            onclick="$('input#solrQuery').val(''); $('input.clear_taxon').click(); return true;"
        />
    </div>
</form>

<r:script>
    $(document).ready(function() {
        $('.bscombobox').combobox({bsVersion: '2'});
    });
</r:script>
