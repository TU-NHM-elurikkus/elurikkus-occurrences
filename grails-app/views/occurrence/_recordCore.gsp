<%@ page import="groovy.json.JsonSlurper" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<g:set var="fieldsMap" value="${[:]}" />

<div>
    <g:render template="sandboxUploadSourceLinks" model="[dataResourceUid: record?.raw?.attribution?.dataResourceUid]" />

    <h3>
        <g:message code="recordcore.occurencedataset.title" />
    </h3>

    <table class="occurrenceTable table table-sm table-bordered" id="datasetTable">
        <!-- Data Provider -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="dataProvider" fieldName="${message(code: 'recordcore.dataset.dataProvider')}">
            ${fieldsMap.put("dataProviderName", true)}
            ${record.processed.attribution.dataProviderName}
        </alatag:occurrenceTableRow>

        <!-- Data Resource -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="dataResource" fieldName="${message(code: 'recordcore.dataset.dataResource')}">
            ${fieldsMap.put("dataResourceName", true)}
            <g:if test="${record.raw.attribution.dataResourceUid != null && record.raw.attribution.dataResourceUid && collectionsWebappContext}">
                ${fieldsMap.put("dataResourceUid", true)}
                <a href="${collectionsWebappContext}/public/show/${record.raw.attribution.dataResourceUid}">
                    <span class="fa fa-database"></span>
                    <g:if test="${record.processed.attribution.dataResourceName}">
                        ${record.processed.attribution.dataResourceName}
                    </g:if>
                    <g:else>
                        ${record.raw.attribution.dataResourceUid}
                    </g:else>
                </a>
            </g:if>
            <g:else>
                ${record.processed.attribution.dataResourceName}
            </g:else>
        </alatag:occurrenceTableRow>

        <!-- Institution -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="institutionCode" fieldName="${message(code: 'recordcore.dataset.Institution')}">
            ${fieldsMap.put("institutionName", true)}
            <g:if test="${record.processed.attribution.institutionUid && collectionsWebappContext}">
                ${fieldsMap.put("institutionUid", true)}
                <a href="${collectionsWebappContext}/public/show/${record.processed.attribution.institutionUid}">
                    <span class="fa fa-university"></span>
                    ${record.processed.attribution.institutionName}
                </a>
            </g:if>
            <g:else>
                ${record.processed.attribution.institutionName}
            </g:else>

            <g:if test="${record.raw.occurrence.institutionCode}">
                ${fieldsMap.put("institutionCode", true)}
                <g:if test="${record.processed.attribution.institutionName}">
                    <br />
                </g:if>
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.institutionCode}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Collection -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldNameIsMsgCode="true" fieldCode="collectionCode" fieldName="${message(code: 'recordcore.dataset.Collection')}">
            <g:if test="${record.processed.attribution.collectionUid && collectionsWebappContext}">
                ${fieldsMap.put("collectionUid", true)}
                <a href="${collectionsWebappContext}/public/show/${record.processed.attribution.collectionUid}">
                    <span class="fa fa-archive"></span>
            </g:if>
            <g:if test="${record.processed.attribution.collectionName}">
                ${fieldsMap.put("collectionName", true)}
                ${record.processed.attribution.collectionName}
            </g:if>
            <g:elseif test="${collectionName}">
                ${fieldsMap.put("collectionName", true)}
                ${collectionName}
            </g:elseif>
            <g:if test="${record.processed.attribution.collectionUid && collectionsWebappContext}">
                </a>
            </g:if>
            <g:if test="${false && record.raw.occurrence.collectionCode}">
                ${fieldsMap.put("collectionCode", true)}
                <g:if test="${collectionName || record.processed.attribution.collectionName}">
                    <br />
                </g:if>
                <span class="originalValue" style="display:none">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.collectionCode}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Catalog Number -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="catalogueNumber" fieldName="${message(code: 'recordcore.dataset.catalogueNumber')}">
            ${fieldsMap.put("catalogNumber", true)}
            <g:if test="${record.processed.occurrence.catalogNumber && record.raw.occurrence.catalogNumber}">
                ${record.processed.occurrence.catalogNumber}
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.catalogNumber}"
                </span>
            </g:if>
            <g:else>
                ${record.raw.occurrence.catalogNumber}
            </g:else>
        </alatag:occurrenceTableRow>

        <!-- Other Catalog Number -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="otherCatalogNumbers" fieldName="${message(code: 'recordcore.dataset.otherCatalogNumbers')}">
            ${fieldsMap.put("otherCatalogNumbers", true)}
            ${record.raw.occurrence.otherCatalogNumbers}
        </alatag:occurrenceTableRow>

        <!-- Occurrence ID -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceID" fieldName="${message(code: 'recordcore.dataset.occurrenceID')}">
            ${fieldsMap.put("occurrenceID", true)}
            <g:if test="${record.processed.occurrence.occurrenceID && record.raw.occurrence.occurrenceID}">
                ${record.processed.occurrence.occurrenceID}
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.occurrenceID}"
                </span>
            </g:if>
            <g:else>
                ${record.raw.occurrence.occurrenceID}
            </g:else>
        </alatag:occurrenceTableRow>

        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="citation" fieldName="${message(code: 'recordcore.dataset.citation')}">
            ${fieldsMap.put("citation", true)}
            ${record.raw.attribution.citation}
        </alatag:occurrenceTableRow>

        <!-- Basis of Record -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="basisOfRecord" fieldName="${message(code: 'recordcore.dataset.basisOfRecord')}">
            ${fieldsMap.put("basisOfRecord", true)}
            <g:if test="${record.processed.occurrence.basisOfRecord && record.raw.occurrence.basisOfRecord && record.processed.occurrence.basisOfRecord == record.raw.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}" />
            </g:if>
            <g:elseif test="${record.processed.occurrence.basisOfRecord && record.raw.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}" />
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.basisOfRecord}"
                </span>
            </g:elseif>
            <g:elseif test="${record.processed.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}" />
            </g:elseif>
            <g:elseif test="${!record.raw.occurrence.basisOfRecord}">
                <g:message code="recordcore.label.recordbasisempty" />
            </g:elseif>
            <g:else>
                <g:message code="${record.raw.occurrence.basisOfRecord}" />
            </g:else>
        </alatag:occurrenceTableRow>

        <!-- Occurrence type -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceType" fieldName="${message(code: 'recordcore.dataset.occurrenceType')}">
            ${fieldsMap.put("type", true)}
            <g:message code="facet.occurrence_type.${record.raw.miscProperties.type}" default="${record.raw.miscProperties.type}" />
        </alatag:occurrenceTableRow>

        <!-- Preparations -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="preparations" fieldName="${message(code: 'recordcore.dataset.preparations')}">
            ${fieldsMap.put("preparations", true)}
            ${record.raw.occurrence.preparations}
        </alatag:occurrenceTableRow>

        <!-- Identifier Name -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identifierName" fieldNameIsMsgCode="true" fieldName="${message(code: 'recordcore.dataset.identifierName')}">
            ${fieldsMap.put("identifiedBy", true)}
            ${record.raw.identification.identifiedBy}
        </alatag:occurrenceTableRow>

        <!-- Identified Date -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identifierDate" fieldNameIsMsgCode="true" fieldName="${message(code: 'recordcore.dataset.identifierDate')}">
            ${fieldsMap.put("identifierDate", true)}
            ${record.raw.identification.dateIdentified}
        </alatag:occurrenceTableRow>

        <!-- Identifier Role -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identifierRole" fieldNameIsMsgCode="true" fieldName="${message(code: 'recordcore.dataset.identifierRole')}">
            ${fieldsMap.put("identifierRole", true)}
            ${record.raw.identification.identifierRole}
        </alatag:occurrenceTableRow>

        <!-- Collector/Observer -->
        <g:set var="collectorNameLabel">
            <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'observation')}">
                <g:message code="recordcore.collectornamelabel.01" />
            </g:if>
            <g:else>
                <g:message code="recordcore.collectornamelabel.02" />
            </g:else>
        </g:set>

        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="collectorName" fieldName="${collectorNameLabel}">
            <g:set var="recordedByField">
                <g:if test="${record.raw.occurrence.recordedBy}">
                    <g:message code="recordcore.recorededbyfield.01" />
                </g:if>
                <g:elseif test="${record.raw.occurrence.userId}">
                    <g:message code="recordcore.recorededbyfield.02" />
                </g:elseif>
                <g:else>
                    <g:message code="recordcore.recorededbyfield.01" />
                </g:else>
            </g:set>

            <g:set var="recordedByField" value="${recordedByField.trim()}" />
            ${fieldsMap.put(recordedByField, true)}

            <g:set var="rawRecordedBy" value="${record.raw.occurrence[recordedByField]}" />
            <g:set var="proRecordedBy" value="${record.processed.occurrence[recordedByField]}" />

            <g:if test="${proRecordedBy}">
                ${proRecordedBy}
            </g:if>
            <g:elseif test="${rawRecordedBy}">
                <g:message code="recordcore.label.suppliedas" /> "${rawRecordedBy}"
            </g:elseif>
        </alatag:occurrenceTableRow>

        <!-- ALA user id -->
        <g:if test="${record.raw.occurrence.userId}">
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="userId" fieldNameIsMsgCode="true" fieldName="${message(code: 'recordcore.dataset.userId')}">
                <a href="${grailsApplication.config.sightings.baseUrl}/spotter/${record.raw.occurrence.userId}">
                    ${record.alaUserName}
                </a>
            </alatag:occurrenceTableRow>
        </g:if>

        <!-- Record Number -->
        <g:set var="recordNumberLabel">
            <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'specimen')}">
                <g:message code="recordcore.recordnumber.label.01" />
            </g:if>
            <g:else>
                <g:message code="recordcore.recordnumber.label.02" />
            </g:else>
        </g:set>

        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="recordNumber" fieldName="${recordNumberLabel}">
            ${fieldsMap.put("recordNumber", true)}

            <g:if test="${record.processed.occurrence.recordNumber && record.raw.occurrence.recordNumber}">
                ${record.processed.occurrence.recordNumber}
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.occurrence.recordNumber}"
                </span>
            </g:if>
            <g:else>
                <g:if test="${record.raw.occurrence.recordNumber && StringUtils.startsWith(record.raw.occurrence.recordNumber,'http://')}">
                    <a href="${record.raw.occurrence.recordNumber}" target="_blank" >
                </g:if>

                ${record.raw.occurrence.recordNumber}

                <g:if test="${record.raw.occurrence.recordNumber && StringUtils.startsWith(record.raw.occurrence.recordNumber,'http://')}">
                    </a>
                </g:if>
            </g:else>
        </alatag:occurrenceTableRow>

        <!-- Type Status -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="typeStatus" fieldName="${message(code: 'recordcore.dataset.typeStatus')}">
            ${fieldsMap.put("typeStatus", true)}
            <g:if test="${record.processed.identification.typeStatus}">
                <span style="text-transform: capitalize;">
                    ${record.processed.identification.typeStatus}
                </span>
            </g:if>
            <g:else>
                ${record.raw.identification.typeStatus}
            </g:else>
            <g:if test="${record.processed.identification.typeStatus && record.raw.identification.typeStatus && (record.processed.identification.typeStatus.toLowerCase() != record.raw.identification.typeStatus.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.identification.typeStatus}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Identification Qualifier -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identificationQualifier" fieldName="${message(code: 'recordcore.dataset.identificationQualifier')}">
            ${fieldsMap.put("identificationQualifier", true)}
            ${record.raw.identification.identificationQualifier}
        </alatag:occurrenceTableRow>

        <!-- Reproductive Condition -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="reproductiveCondition" fieldName="${message(code: 'recordcore.dataset.reproductiveCondition')}">
            ${fieldsMap.put("reproductiveCondition", true)}
            ${record.raw.occurrence.reproductiveCondition}
        </alatag:occurrenceTableRow>

        <!-- Sex -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="sex" fieldName="${message(code: 'recordcore.dataset.sex')}">
            ${fieldsMap.put("sex", true)}
            ${record.raw.occurrence.sex}
        </alatag:occurrenceTableRow>

        <!-- Behavior -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="behavior" fieldName="${message(code: 'recordcore.dataset.behavior')}">
            ${fieldsMap.put("behavior", true)}
            ${record.raw.occurrence.behavior}
        </alatag:occurrenceTableRow>

        <!-- Individual count -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="individualCount" fieldName="${message(code: 'recordcore.dataset.individualCount')}">
            ${fieldsMap.put("individualCount", true)}
            ${record.raw.occurrence.individualCount}
        </alatag:occurrenceTableRow>

        <!-- Organism quantity -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="organismQuantity" fieldName="${message(code: 'recordcore.dataset.organismQuantity')}">
            ${fieldsMap.put("organismQuantity", true)}
            ${fieldsMap.put("organismQuantityType", true)}
            ${record.raw.occurrence.organismQuantity}
            <g:if test="${record.raw.miscProperties.organismQuantityType}">
                (<g:message code="recordcore.dataset.organismQuantityType.${record.raw.miscProperties.organismQuantityType}" default="${record.raw.miscProperties.organismQuantityType}"/>)
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Life stage -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="lifeStage" fieldName="${message(code: 'recordcore.dataset.lifeStage')}">
            ${fieldsMap.put("lifeStage", true)}
            ${record.raw.occurrence.lifeStage}
        </alatag:occurrenceTableRow>

        <g:if test="${record.processed.occurrence.basisOfRecord == 'HumanObservation'}">
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="breeding" fieldName="${message(code: 'recordcore.dataset.breeding')}">
                ${fieldsMap.put("breeding", true)}
                <g:set var="jsonSlurper" value="${new JsonSlurper()}" />
                <g:set var="object" value="${jsonSlurper.parseText(record.raw.occurrence.dynamicProperties ?: '{}')}" />
                ${object.breeding}
            </alatag:occurrenceTableRow>
        </g:if>

        <!-- Rights -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="rights" fieldName="${message(code: 'recordcore.dataset.rights')}">
            ${fieldsMap.put("rights", true)}
            ${record.raw.occurrence.rights}
        </alatag:occurrenceTableRow>

        <!-- Occurrence details -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="occurrenceDetails" fieldName="${message(code: 'recordcore.dataset.occurrenceDetails')}">
            ${fieldsMap.put("occurrenceDetails", true)}
            <g:if test="${record.raw.occurrence.occurrenceDetails && StringUtils.startsWith(record.raw.occurrence.occurrenceDetails,'http://')}">
                <a href="${record.raw.occurrence.occurrenceDetails}" target="_blank">
                    ${record.raw.occurrence.occurrenceDetails}
                </a>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- associatedOccurrences - handles the duplicates that are added via ALA Duplication Detection -->
         <g:if test="${record.processed.occurrence.duplicationStatus}">
            ${fieldsMap.put("duplicationStatus", true)}
            ${fieldsMap.put("associatedOccurrences", true)}

            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="duplicationStatus" fieldName="${message(code: 'recordcore.dataset.duplicationStatus')}">
                <g:message code="duplication.${record.processed.occurrence.duplicationStatus}" default="${record.processed.occurrence.duplicationStatus}" />
            </alatag:occurrenceTableRow>

            <!-- Now handle the associatedOccurrences -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="associatedOccurrences" fieldName="${message(code: 'recordcore.dataset.InferredAssociatedOccurrences')}">
                <g:if test="${record.processed.occurrence.duplicationStatus == 'R'}">
                    <g:message code="recordcore.iao.01" />
                    ${record.processed.occurrence.associatedOccurrences.tokenize("|").size() } <g:message code="recordcore.iao.01.02" />
                </g:if>
                <g:else>
                    <g:message code="recordcore.iao.02" />.
                </g:else>

                <br />

                <g:message code="recordcore.iao.03" />

                <a href="#inferredOccurrenceDetails">
                    <g:message code="recordcore.iao.04" />
                </a>
            </alatag:occurrenceTableRow>

            <g:if test="${record.raw.occurrence.associatedOccurrences }">
                <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="associatedOccurrences" fieldName="${message(code: 'recordcore.dataset.AssociatedOccurrences')}">
                    ${record.raw.occurrence.associatedOccurrences }
                </alatag:occurrenceTableRow>
            </g:if>
        </g:if>

        <!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Attribution" exclude="${dwcExcludeFields}" />
        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Occurrence" exclude="${dwcExcludeFields}" />
        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Identification" exclude="${dwcExcludeFields}" />
    </table>
</div>

<div>
    <h3>
        <g:message code="recordcore.occurenceevent.title" />
    </h3>

    <table class="occurrenceTable table table-sm table-bordered" id="eventTable">
        <!-- Field Number -->
        <alatag:occurrenceTableRow annotate="true" section="event" fieldCode="fieldNumber" fieldName="${message(code: 'recordcore.event.fieldNumber')}">
            ${fieldsMap.put("fieldNumber", true)}
            ${record.raw.occurrence.fieldNumber}
        </alatag:occurrenceTableRow>

        <!-- Identification remarks -->
        <alatag:occurrenceTableRow annotate="true" section="event" fieldCode="identificationRemarks" fieldNameIsMsgCode="true" fieldName="${message(code: 'recordcore.event.identificationRemarks')}">
            ${fieldsMap.put("identificationRemarks", true)}
            ${record.raw.identification.identificationRemarks}
        </alatag:occurrenceTableRow>

        <!-- Record Date -->
        <g:set var="occurrenceDateLabel">
            <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'observation')}">
                <g:message code="recordcore.occurrencedatelabel.observation" />
            </g:if>
            <g:elseif test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'specimen')}">
                <g:message code="recordcore.occurrencedatelabel.specimen" />
            </g:elseif>
            <g:else>
                <g:message code="recordcore.occurrencedatelabel.occurrenceDate" />
            </g:else>
        </g:set>

        <alatag:occurrenceTableRow annotate="true" section="event" fieldCode="occurrenceDate" fieldName="${occurrenceDateLabel}">
            ${fieldsMap.put("eventDate", true)}

            <g:if test="${!record.processed.event.eventDate && (record.processed.event.year || record.processed.event.month || record.processed.event.day)}">
                [<g:message code="recordcore.occurrencedatelabel.02" />]
            </g:if>
            <g:elseif test="${!record.processed.event.eventDate && record.raw.event.eventDate && !record.raw.event.year && !record.raw.event.month && !record.raw.event.day}">
                [<g:message code="recordcore.occurrencedatelabel.03" />]
            </g:elseif>

            <g:if test="${record.processed.event.eventDate}">
                <span class="isoDate">${record.processed.event.eventDate}</span>
            </g:if>

            <g:if test="${!record.processed.event.eventDate && (record.processed.event.year || record.processed.event.month || record.processed.event.day)}">
                <g:if test="${record.processed.event.year}">
                    <g:message code="recordcore.occurrencedatelabel.04" />: ${record.processed.event.year}
                </g:if>
                <g:if test="${record.processed.event.month}">
                    <g:message code="recordcore.occurrencedatelabel.05" />: ${record.processed.event.month}
                </g:if>
                <g:if test="${record.processed.event.day}">
                    <g:message code="recordcore.occurrencedatelabel.06" />: ${record.processed.event.day}
                </g:if>
            </g:if>

            <g:if test="${record.processed.event.eventDate && record.raw.event.eventDate && record.raw.event.eventDate != record.processed.event.eventDate}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.event.eventDate}"
                </span>
            </g:if>
            <g:elseif test="${record.raw.event.year || record.raw.event.month || record.raw.event.day}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" />
                    <g:if test="${record.raw.event.year}">
                        <g:message code="recordcore.occurrencedatelabel.09" /> ${record.raw.event.year}&nbsp;
                    </g:if>
                    <g:if test="${record.raw.event.month}">
                        <g:message code="recordcore.occurrencedatelabel.10" /> ${record.raw.event.month}&nbsp;
                    </g:if>
                    <g:if test="${record.raw.event.day}">
                        <g:message code="recordcore.occurrencedatelabel.11" /> ${record.raw.event.day}&nbsp;
                    </g:if>
                </span>
            </g:elseif>
            <g:elseif test="${record.raw.event.eventDate != record.processed.event.eventDate && record.raw.event.eventDate}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${record.raw.event.eventDate}"
                </span>
            </g:elseif>
        </alatag:occurrenceTableRow>

        <!-- Sampling Protocol -->
        <alatag:occurrenceTableRow annotate="true" section="event" fieldCode="samplingProtocol" fieldName="${message(code: 'recordcore.event.samplingProtocol')}">
            ${fieldsMap.put("samplingProtocol", true)}
            ${record.raw.occurrence.samplingProtocol}
        </alatag:occurrenceTableRow>

        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Event" exclude="${dwcExcludeFields}" />
    </table>
</div>

<div>
    <h3>
        <g:message code="recordcore.occurencetaxonomy.title" />
    </h3>

    <g:set var="classification" value="${record.processed.classification}" />
    <g:set var="rawClassification" value="${record.raw.classification}" />

    <table class="occurrenceTable table table-sm table-bordered" id="taxonomyTable">
        <!-- Higher classification -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="higherClassification" fieldName="${message(code: 'recordcore.taxonomy.higherClassification')}">
            ${fieldsMap.put("higherClassification", true)}
            ${rawClassification.higherClassification}
        </alatag:occurrenceTableRow>

        <!-- Scientific name -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="scientificName" fieldName="${message(code: 'recordcore.taxonomy.scientificName')}">
            ${fieldsMap.put("taxonConceptID", true)}
            ${fieldsMap.put("scientificName", true)}

            <g:if test="${taxaLinks.baseUrl && classification.taxonConceptID}">
                <a href="${taxaLinks.baseUrl + classification.taxonConceptID}">
                    <span class="fa fa-tag"></span>
            </g:if>

            <g:if test="${classification.taxonRankID?.toInteger() > 5000}">
                <i>
            </g:if>
            ${classification.scientificName ?: ''}
            <g:if test="${classification.taxonRankID?.toInteger() > 5000}">
                </i>
            </g:if>

            <g:if test="${taxaLinks.baseUrl && classification.taxonConceptID}">
                </a>
            </g:if>

            <g:if test="${classification.scientificName && rawClassification.scientificName && (classification.scientificName.toLowerCase() != rawClassification.scientificName.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.scientificName}"
                </span>
            </g:if>

            <g:if test="${!classification.scientificName && rawClassification.scientificName}">
                ${rawClassification.scientificName}
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- original name usage -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="originalNameUsage" fieldName="${message(code: 'recordcore.taxonomy.originalNameUsage')}">
            ${fieldsMap.put("originalNameUsage", true)}
            ${fieldsMap.put("originalNameUsageID", true)}

            <g:if test="${classification.originalNameUsageID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl + classification.originalNameUsageID}">
                        <span class="fa fa-tag"></span>
                </g:if>
            </g:if>

            <g:if test="${classification.originalNameUsage}">
                ${classification.originalNameUsage}
            </g:if>

            <g:if test="${!classification.originalNameUsage && rawClassification.originalNameUsage}">
                ${rawClassification.originalNameUsage}
            </g:if>

            <g:if test="${taxaLinks.baseUrl && classification.originalNameUsageID}">
                </a>
            </g:if>

            <g:if test="${classification.originalNameUsage && rawClassification.originalNameUsage && (classification.originalNameUsage.toLowerCase() != rawClassification.originalNameUsage.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.originalNameUsage}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Taxon Rank -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonRank" fieldName="${message(code: 'recordcore.taxonomy.taxonRank')}">
            ${fieldsMap.put("taxonRank", true)}
            ${fieldsMap.put("taxonRankID", true)}

            <g:if test="${classification.taxonRank}">
                <span style="text-transform: capitalize;">
                    ${classification.taxonRank}
                </span>
            </g:if>
            <g:elseif test="${!classification.taxonRank && rawClassification.taxonRank}">
                <span style="text-transform: capitalize;">
                    ${rawClassification.taxonRank}
                </span>
            </g:elseif>
            <g:else>
                [<g:message code="recordcore.tr01" />]
            </g:else>

            <g:if test="${classification.taxonRank && rawClassification.taxonRank && (classification.taxonRank.toLowerCase() != rawClassification.taxonRank.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.taxonRank}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Common name -->
        <alatag:occurrenceTableRow annotate="false" section="taxonomy" fieldCode="commonName" fieldName="${message(code: 'recordcore.taxonomy.commonName')}">
            ${fieldsMap.put("vernacularName", true)}

            <g:if test="${classification.vernacularName}">
                ${classification.vernacularName}
            </g:if>

            <g:if test="${!classification.vernacularName && rawClassification.vernacularName}">
                ${rawClassification.vernacularName}
            </g:if>

            <g:if test="${classification.vernacularName && rawClassification.vernacularName && (classification.vernacularName.toLowerCase() != rawClassification.vernacularName.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.vernacularName}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Kingdom -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="kingdom" fieldName="${message(code: 'recordcore.taxonomy.kingdom')}">
            ${fieldsMap.put("kingdom", true)}
            ${fieldsMap.put("kingdomID", true)}

            <g:set var="kingdomName" value="${classification.kingdom ? classification.kingdom : rawClassification.kingdom}" />
            <g:if test="${classification.kingdomID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.kingdomID}">
                    <span class="fa fa-tag"></span>
                    ${kingdomName}
                </a>
            </g:if>
            <g:else>
                ${kingdomName}
            </g:else>

            <g:if test="${classification.kingdom && rawClassification.kingdom && (classification.kingdom.toLowerCase() != rawClassification.kingdom.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.kingdom}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Phylum -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="phylum" fieldName="${message(code: 'recordcore.taxonomy.phylum')}">
            ${fieldsMap.put("phylum", true)}
            ${fieldsMap.put("phylumID", true)}

            <g:set var="phylumName" value="${classification.phylum ? classification.phylum : rawClassification.phylum}" />
            <g:if test="${classification.phylumID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.phylumID}">
                    <span class="fa fa-tag"></span>
                    ${phylumName}
                </a>
            </g:if>
            <g:else>
                ${phylumName}
            </g:else>

            <g:if test="${classification.phylum && rawClassification.phylum && (classification.phylum.toLowerCase() != rawClassification.phylum.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.phylum}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Class -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="classs" fieldName="${message(code: 'recordcore.taxonomy.class')}">
            ${fieldsMap.put("classs", true)}
            ${fieldsMap.put("classID", true)}

            <g:set var="className" value="${classification.classs ? classification.classs : rawClassification.classs}" />
            <g:if test="${classification.classID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.classID}">
                    <span class="fa fa-tag"></span>
                    ${className}
                </a>
            </g:if>
            <g:else>
                ${className}
            </g:else>

            <g:if test="${classification.classs && rawClassification.classs && (classification.classs.toLowerCase() != rawClassification.classs.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.classs}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Order -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="order" fieldName="${message(code: 'recordcore.taxonomy.order')}">
            ${fieldsMap.put("order", true)}
            ${fieldsMap.put("orderID", true)}

            <g:set var="orderName" value="${classification.order ? classification.order : rawClassification.order}" />
            <g:if test="${classification.orderID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.orderID}">
                    <span class="fa fa-tag"></span>
                    ${orderName}
                </a>
            </g:if>
            <g:else>
                ${orderName}
            </g:else>

            <g:if test="${classification.order && rawClassification.order && (classification.order.toLowerCase() != rawClassification.order.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.order}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Family -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="family" fieldName="${message(code: 'recordcore.taxonomy.family')}">
            ${fieldsMap.put("family", true)}
            ${fieldsMap.put("familyID", true)}

            <g:set var="familyName" value="${classification.family ? classification.family : rawClassification.family}" />
            <g:if test="${classification.familyID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.familyID}">
                    <span class="fa fa-tag"></span>
                    ${familyName}
                </a>
            </g:if>
            <g:else>
                ${familyName}
            </g:else>

            <g:if test="${classification.family && rawClassification.family && (classification.family.toLowerCase() != rawClassification.family.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" /> "${rawClassification.family}"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Genus -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="genus" fieldName="${message(code: 'recordcore.taxonomy.genus')}">
            ${fieldsMap.put("genus", true)}
            ${fieldsMap.put("genusID", true)}

            <g:set var="genusName" value="${classification.genus ? classification.genus : rawClassification.genus}" />
            <g:if test="${classification.genusID && taxaLinks.baseUrl}">
                <a href="${taxaLinks.baseUrl + classification.genusID}">
                    <span class="fa fa-tag"></span>
                    <i>${genusName}</i>
                </a>
            </g:if>
            <g:else>
                <i>${genusName}</i>
            </g:else>

            <g:if test="${classification.genus && rawClassification.genus && (classification.genus.toLowerCase() != rawClassification.genus.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.genus.01" />
                    "<i>${rawClassification.genus}</i>"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Species -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="species" fieldName="${message(code: 'recordcore.taxonomy.species')}">
            ${fieldsMap.put("species", true)}
            ${fieldsMap.put("speciesID", true)}
            ${fieldsMap.put("specificEpithet", true)}

            <g:if test="${classification.speciesID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl + classification.speciesID}">
                        <span class="fa fa-tag"></span>
                </g:if>
            </g:if>

            <g:if test="${classification.species}">
                <i>${classification.species}</i>
            </g:if>
            <g:elseif test="${rawClassification.species}">
                <i>${rawClassification.species}</i>
            </g:elseif>
            <g:elseif test="${rawClassification.specificEpithet && rawClassification.genus}">
                <i>
                    ${rawClassification.genus}&nbsp;${rawClassification.specificEpithet}
                </i>
            </g:elseif>

            <g:if test="${taxaLinks.baseUrl && classification.speciesID}">
                </a>
            </g:if>

            <g:if test="${classification.species && rawClassification.species && (classification.species.toLowerCase() != rawClassification.species.toLowerCase())}">
                <br />
                <span class="originalValue">
                    <g:message code="recordcore.label.suppliedas" />
                    "<i>${rawClassification.species}</i>"
                </span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Associated Taxa -->
        <g:if test="${record.raw.occurrence.associatedTaxa}">
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="associatedTaxa" fieldName="${message(code: 'recordcore.taxonomy.associatedTaxa')}">
                ${fieldsMap.put("associatedTaxa", true)}
                <g:set var="colon" value=":" />
                <g:if test="${taxaLinks.baseUrl && StringUtils.contains(record.raw.occurrence.associatedTaxa,colon)}">
                    <g:set var="associatedName" value="${StringUtils.substringAfter(record.raw.occurrence.associatedTaxa,colon)}" />
                    ${StringUtils.substringBefore(record.raw.occurrence.associatedTaxa,colon) }:
                    <a href="${taxaLinks.baseUrl + StringUtils.replace(associatedName, '  ', ' ')}">
                        <span class="fa fa-tag"></span>
                        ${associatedName}
                    </a>
                </g:if>
                <g:elseif test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl + StringUtils.replace(record.raw.occurrence.associatedTaxa, '  ', ' ')}">
                        <span class="fa fa-tag"></span>
                        ${record.raw.occurrence.associatedTaxa}
                    </a>
                </g:elseif>
            </alatag:occurrenceTableRow>
        </g:if>

        <g:if test="${classification.taxonomicIssue}">
            <!-- Taxonomic issues -->
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonomicIssue" fieldName="${message(code: 'recordcore.taxonomy.taxonomicIssue')}">
                <g:each var="issue" in="${classification.taxonomicIssue}">
                    <g:message code="${issue}" />
                </g:each>
            </alatag:occurrenceTableRow>
        </g:if>

        <g:if test="${classification.nameMatchMetric}">
            <!-- Name match metric -->
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="nameMatchMetric" fieldName="${message(code: 'recordcore.taxonomy.nameMatchMetric')}">
                <g:message code="${classification.nameMatchMetric}" default="${classification.nameMatchMetric}" />
                <br />
                <g:message code="nameMatch.${classification.nameMatchMetric}" default="" />
            </alatag:occurrenceTableRow>
        </g:if>

        <!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Classification" exclude="${dwcExcludeFields}" />
    </table>
</div>

<g:if test="${compareRecord?.Location}">
    <div>
        <h3>
            <g:message code="recordcore.occurencegeospatial.title" />
        </h3>

        <table class="occurrenceTable table table-sm table-bordered" id="geospatialTable">
            <!-- Higher Geography -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="higherGeography" fieldName="${message(code: 'recordcore.geospatial.higherGeography')}">
                ${fieldsMap.put("higherGeography", true)}
                ${record.raw.location.higherGeography}
            </alatag:occurrenceTableRow>

            <!-- Country -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="country" fieldName="${message(code: 'recordcore.geospatial.country')}">
                ${fieldsMap.put("country", true)}
                <g:if test="${record.processed.location.country}">
                    ${record.processed.location.country}
                </g:if>
                <g:elseif test="${record.processed.location.countryCode}">
                    <g:message code="country.${record.processed.location.countryCode}" />
                </g:elseif>
                <g:else>
                    ${record.raw.location.country}
                </g:else>
                <g:if test="${record.processed.location.country && record.raw.location.country && (record.processed.location.country.toLowerCase() != record.raw.location.country.toLowerCase())}">
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.country}"
                    </span>
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- State/Province -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="state" fieldName="${message(code: 'recordcore.geospatial.state')}">
                ${fieldsMap.put("stateProvince", true)}
                <g:set var="stateValue" value="${record.processed.location.stateProvince ? record.processed.location.stateProvince : record.raw.location.stateProvince}" />
                <g:if test="${stateValue}">
                    ${stateValue}
                </g:if>
                <g:if test="${record.processed.location.stateProvince && record.raw.location.stateProvince && (record.processed.location.stateProvince.toLowerCase() != record.raw.location.stateProvince.toLowerCase())}">
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.stateProvince}"
                    </span>
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Local Govt Area -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="localGovArea" fieldName="${message(code: 'recordcore.geospatial.localGovArea')}">
                ${fieldsMap.put("lga", true)}
                <g:if test="${record.processed.location.lga}">
                    ${record.processed.location.lga}
                </g:if>
                <g:if test="${!record.processed.location.lga && record.raw.location.lga}">
                    ${record.raw.location.lga}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Locality -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locality" fieldName="${message(code: 'recordcore.geospatial.locality')}">
                ${fieldsMap.put("locality", true)}
                <g:if test="${record.processed.location.locality}">
                    ${record.processed.location.locality}
                </g:if>
                <g:if test="${!record.processed.location.locality && record.raw.location.locality}">
                    ${record.raw.location.locality}
                </g:if>
                <g:if test="${record.processed.location.locality && record.raw.location.locality && (record.processed.location.locality.toLowerCase() != record.raw.location.locality.toLowerCase())}">
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.locality}"
                    </span>
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Biogeographic Region -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="biogeographicRegion" fieldName="${message(code: 'recordcore.geospatial.biogeographicRegion')}">
                ${fieldsMap.put("ibra", true)}
                <g:if test="${record.processed.location.ibra}">
                    ${record.processed.location.ibra}
                </g:if>
                <g:if test="${!record.processed.location.ibra && record.raw.location.ibra}">
                    ${record.raw.location.ibra}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Habitat -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="habitat" fieldName="${message(code: 'recordcore.geospatial.habitat')}">
                ${fieldsMap.put("habitat", true)}
                ${record.processed.location.habitat}
                <g:if test="${record.raw.location.habitat && record.raw.location.habitat != record.processed.location.habitat}">
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.habitat}"
                    </span>
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Latitude -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="latitude" fieldName="${message(code: 'recordcore.geospatial.latitude')}">
                ${fieldsMap.put("decimalLatitude", true)}
                <g:if test="${clubView && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                    ${record.raw.location.decimalLatitude}
                </g:if>
                <g:elseif test="${record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                    ${record.processed.location.decimalLatitude}
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.decimalLatitude}"
                    </span>
                </g:elseif>
                <g:elseif test="${record.processed.location.decimalLatitude}">
                    ${record.processed.location.decimalLatitude}
                </g:elseif>
                <g:elseif test="${record.raw.location.decimalLatitude}">
                    ${record.raw.location.decimalLatitude}
                </g:elseif>
            </alatag:occurrenceTableRow>

            <!-- Longitude -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="longitude" fieldName="${message(code: 'recordcore.geospatial.longitude')}">
                ${fieldsMap.put("decimalLongitude", true)}
                <g:if test="${clubView && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                    ${record.raw.location.decimalLongitude}
                </g:if>
                <g:elseif test="${record.raw.location.decimalLongitude && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                    ${record.processed.location.decimalLongitude}
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.decimalLongitude}"
                    </span>
                </g:elseif>
                <g:elseif test="${record.processed.location.decimalLongitude}">
                    ${record.processed.location.decimalLongitude}
                </g:elseif>
                <g:elseif test="${record.raw.location.decimalLongitude}">
                    ${record.raw.location.decimalLongitude}
                </g:elseif>
            </alatag:occurrenceTableRow>

            <!-- Geodetic datum -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="geodeticDatum" fieldName="${message(code: 'recordcore.geospatial.geodeticDatum')}">
                ${fieldsMap.put("geodeticDatum", true)}
                <g:if test="${clubView && record.raw.location.geodeticDatum != record.processed.location.geodeticDatum}">
                    ${record.raw.location.geodeticDatum}
                </g:if>
                <g:elseif test="${record.raw.location.geodeticDatum && record.raw.location.geodeticDatum != record.processed.location.geodeticDatum}">
                    ${record.processed.location.geodeticDatum}
                    <br />
                    <span class="originalValue">
                        <g:message code="recordcore.label.suppliedas" /> "${record.raw.location.geodeticDatum}"
                    </span>
                </g:elseif>
                <g:elseif test="${record.processed.location.geodeticDatum}">
                    ${record.processed.location.geodeticDatum}
                </g:elseif>
                <g:elseif test="${record.raw.location.geodeticDatum}">
                    ${record.raw.location.geodeticDatum}
                </g:elseif>
            </alatag:occurrenceTableRow>

            <!-- verbatimCoordinateSystem -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="verbatimCoordinateSystem" fieldName="${message(code: 'recordcore.geospatial.verbatimCoordinateSystem')}">
                ${fieldsMap.put("verbatimCoordinateSystem", true)}
                ${record.raw.location.verbatimCoordinateSystem}
            </alatag:occurrenceTableRow>

            <!-- Verbatim locality -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="verbatimLocality" fieldName="${message(code: 'recordcore.geospatial.verbatimLocality')}">
                ${fieldsMap.put("verbatimLocality", true)}
                ${record.raw.location.verbatimLocality}
            </alatag:occurrenceTableRow>

            <!-- Water Body -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="waterBody" fieldName="${message(code: 'recordcore.geospatial.waterBody')}">
                ${fieldsMap.put("waterBody", true)}
                ${record.raw.location.waterBody}
            </alatag:occurrenceTableRow>

            <!-- Min depth -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="minimumDepthInMeters" fieldName="${message(code: 'recordcore.geospatial.minimumDepthInMeters')}">
                ${fieldsMap.put("minimumDepthInMeters", true)}
                ${record.raw.location.minimumDepthInMeters}
            </alatag:occurrenceTableRow>

            <!-- Max depth -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="maximumDepthInMeters" fieldName="${message(code: 'recordcore.geospatial.maximumDepthInMeters')}">
                ${fieldsMap.put("maximumDepthInMeters", true)}
                ${record.raw.location.maximumDepthInMeters}
            </alatag:occurrenceTableRow>

            <!-- Min elevation -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="minimumElevationInMeters" fieldName="${message(code: 'recordcore.geospatial.minimumElevationInMeters')}">
                ${fieldsMap.put("minimumElevationInMeters", true)}
                ${record.raw.location.minimumElevationInMeters}
            </alatag:occurrenceTableRow>

            <!-- Max elevation -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="maximumElevationInMeters" fieldName="${message(code: 'recordcore.geospatial.maximumElevationInMeters')}">
                ${fieldsMap.put("maximumElevationInMeters", true)}
                ${record.raw.location.maximumElevationInMeters}
            </alatag:occurrenceTableRow>

            <!-- Island -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="island" fieldName="${message(code: 'recordcore.geospatial.island')}">
                ${fieldsMap.put("island", true)}
                ${record.raw.location.island}
            </alatag:occurrenceTableRow>

            <!-- Island Group-->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="islandGroup" fieldName="${message(code: 'recordcore.geospatial.islandGroup')}">
                ${fieldsMap.put("islandGroup", true)}
                ${record.raw.location.islandGroup}
            </alatag:occurrenceTableRow>

            <!-- Location remarks -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locationRemarks" fieldName="${message(code: 'recordcore.geospatial.locationRemarks')}">
                ${fieldsMap.put("locationRemarks", true)}
                ${record.raw.location.locationRemarks}
            </alatag:occurrenceTableRow>

            <!-- Field notes -->
            <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="fieldNotes" fieldName="${message(code: 'recordcore.geospatial.fieldNotes')}">
                ${fieldsMap.put("fieldNotes", true)}
                ${record.raw.occurrence.fieldNotes}
            </alatag:occurrenceTableRow>

            <!-- Coordinate Precision -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="coordinatePrecision" fieldName="${message(code: 'recordcore.geospatial.coordinatePrecision')}">
                ${fieldsMap.put("coordinatePrecision", true)}
                <g:if test="${record.raw.location.decimalLatitude || record.raw.location.decimalLongitude}">
                    <g:message code="${record.raw.location.coordinatePrecision ? record.raw.location.coordinatePrecision : 'recordcore.record.value.unspecified'}" />
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Coordinate Uncertainty -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="coordinateUncertaintyInMeters" fieldName="${message(code: 'recordcore.geospatial.coordinateUncertaintyInMeters')}">
                ${fieldsMap.put("coordinateUncertaintyInMeters", true)}
                <g:if test="${record.processed.location.coordinateUncertaintyInMeters}">
                    <g:message code="${record.processed.location.coordinateUncertaintyInMeters ? record.processed.location.coordinateUncertaintyInMeters : 'recordcore.record.value.unspecified'}" />
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Data Generalizations -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="generalisedInMetres" fieldName="${message(code: 'recordcore.geospatial.generalisedInMetres')}">
                ${fieldsMap.put("generalisedInMetres", true)}
                <g:if test="${record.processed.occurrence.dataGeneralizations && StringUtils.contains(record.processed.occurrence.dataGeneralizations, 'is already generalised')}">
                    ${record.processed.occurrence.dataGeneralizations}
                </g:if>
                <g:elseif test="${record.processed.occurrence.dataGeneralizations}">
                    <g:message code="recordcore.cg.label" />: &quot;<span class="dataGeneralizations">${record.processed.occurrence.dataGeneralizations}</span>&quot;.
                    ${(clubView) ? 'NOTE: current user has "club view" and thus coordinates are not generalised.' : ''}
                </g:elseif>
            </alatag:occurrenceTableRow>

            <!-- Information Withheld -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="informationWithheld" fieldName="${message(code: 'recordcore.geospatial.informationWithheld')}">
                ${fieldsMap.put("informationWithheld", true)}
                <g:if test="${record.processed.occurrence.informationWithheld}">
                    <span class="dataGeneralizations">
                        ${record.processed.occurrence.informationWithheld}
                    </span>
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- GeoreferenceVerificationStatus -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceVerificationStatus" fieldName="${message(code: 'recordcore.geospatial.georeferenceVerificationStatus')}">
                ${fieldsMap.put("georeferenceVerificationStatus", true)}
                ${record.raw.location.georeferenceVerificationStatus}
            </alatag:occurrenceTableRow>

            <!-- georeferenceSources -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceSources" fieldName="${message(code: 'recordcore.geospatial.georeferenceSources')}">
                ${fieldsMap.put("georeferenceSources", true)}
                ${record.raw.location.georeferenceSources}
            </alatag:occurrenceTableRow>

            <!-- georeferenceProtocol -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceProtocol" fieldName="${message(code: 'recordcore.geospatial.georeferenceProtocol')}">
                ${fieldsMap.put("georeferenceProtocol", true)}
                ${record.raw.location.georeferenceProtocol}
            </alatag:occurrenceTableRow>

            <!-- georeferenceProtocol -->
            <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferencedBy" fieldName="${message(code: 'recordcore.geospatial.georeferencedBy')}">
                ${fieldsMap.put("georeferencedBy", true)}
                ${record.raw.location.georeferencedBy}
            </alatag:occurrenceTableRow>

            <!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
            <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Location" exclude="${dwcExcludeFields}" />
        </table>
    </div>
</g:if>

<g:if test="${record.raw.miscProperties || plutofURL}">
    <div>
        <h3>
            <g:message code="recordcore.addtionalproperties.title" />
        </h3>

        <table class="occurrenceTable table table-sm table-bordered" id="miscellaneousPropertiesTable">
            <!-- Misc properties -->
            <g:if test="${plutofURL}">
                <alatag:occurrenceTableRow annotate="false" section="misc" fieldCode="plutof-link" fieldName="${message(code: 'recordcore.misc.plutofLink.label')}">
                    <a href="${plutofURL}" target="_blank">
                        ${plutofURL}
                    </a>
                </alatag:occurrenceTableRow>
            </g:if>

            <g:each in="${record.raw.miscProperties.sort()}" var="entry">
                <g:if test="${!fieldsMap.containsKey(entry.key)}">
                    <g:set var="label">
                        <g:message code="recordcore.dynamic.${entry.key}" default="${entry.key}" />
                    </g:set>
                    <alatag:occurrenceTableRow annotate="true" section="misc" fieldCode="${entry.key}" fieldName="${label}">
                        <g:if test="${StringUtils.startsWith(entry.value, 'http')}">
                            <a href="${entry.value}" target="_blank">
                                ${entry.value}
                            </a>
                        </g:if>
                        <g:else>
                            <g:message code="recordcore.dynamic.${entry.value}" default="${entry.value}" />
                        </g:else>
                    </alatag:occurrenceTableRow>
                </g:if>
            </g:each>
        </table>
    </div>
</g:if>
