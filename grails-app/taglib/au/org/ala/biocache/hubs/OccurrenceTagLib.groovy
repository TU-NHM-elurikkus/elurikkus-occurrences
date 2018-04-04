/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.biocache.hubs

import groovy.xml.MarkupBuilder
import org.apache.commons.lang.StringUtils
import org.codehaus.groovy.grails.web.util.WebUtils
import org.springframework.web.servlet.support.RequestContextUtils
import grails.util.Environment

class OccurrenceTagLib {
    // injected beans
    def authService
    def webServicesService
    def messageSourceCacheService

    //static defaultEncodeAs = 'html'
    //static encodeAsForTags = [tagName: 'raw']
    static returnObjectForTags = ['getLoggerReasons', 'message']
    static namespace = 'alatag'     // namespace for headers and footers
    static rangePattern = ~/\[\d+(\.\d+)? TO \d+(\.\d+)?\]/

    /**
     * Formats the display of dynamic facet names in Sandbox (facet options popup)
     *
     * @attr fieldName REQUIRED the field name
     */
    def formatDynamicFacetName = { attrs ->
        out << formatFieldName(attrs.fieldName)
    }

    /**
     * Format a dynamic field name.
     *
     * @param fieldName
     * @return
     */
    def formatFieldName(fieldName) {
        def _message = "facet.${fieldName.toLowerCase()}"
        def output = "${alatag.message(code: _message)}"

        if (output == _message) {
            log.debug("No message for: " + _message)
            if (_message.endsWith('_s') || _message.endsWith('_i') || _message.endsWith('_d')) {
                output = fieldName[0..-2].replaceAll("_", " ")
            } else {
                output = fieldName.replaceAll("_", " ")
            }
        }

        StringUtils.capitalize(output)
    }

    /**
     * Format scientific name for HTML display
     *
     * @attr rankId REQUIRED
     * @attr name REQUIRED
     * @attr acceptedName
     */
    def formatSciName = { attrs ->
        def name = attrs.name
        def acceptedName = attrs.acceptedName
        def rankId = attrs.rankId?.toInteger()
        def acceptedNameOutput = ""
        def ital = ["",""]

        if (!rankId || rankId >= 6000) {
            ital = ["<i>","</i>"]
        }

        if (acceptedName) {
            acceptedNameOutput = " (accepted name: ${ital[0]}${acceptedName}${ital[1]})"
        }

        def nameOutput = "${ital[0]}${name}${ital[1]}${acceptedNameOutput}"

        out << nameOutput.trim()
    }

    /**
     * Output the appropriate raw scientific name for the record
     *
     * @attr occurrence REQUIRED the occurrence record (jsonObject)
     */
    def rawScientificName = { attrs ->
        def rec = attrs.occurrence
        def name

        if (rec.raw_scientificName) {
            name = rec.raw_scientificName
        } else if (rec.species) {
            name = rec.species
        } else if (rec.genus) {
            name = rec.genus
        } else if (rec.family) {
            name = rec.family
        } else if (rec.order) {
            name = rec.order
        } else if (rec.phylum) {
            name = rec.phylum
        }  else if (rec.kingdom) {
            name = rec.kingdom
        } else {
            name = g.message(code: "record.noNameSupplied")
        }

        out << name
    }

    /**
     * Generate HTML for current filters
     *
     * @attr item REQUIRED
     * @attr addCheckBox Boolean
     * @attr cssClass String
     * @attr addCloseBtn Boolean
     */
    def currentFilterItem = { attrs ->
        def item = attrs.item
        def exclude = item.value.displayName.startsWith('-')
        def excludeLabel = alatag.message(code: "search.filters.exclude")
        def prefix = exclude ? "<span class='active-filters-prefix'>[${excludeLabel}]</span> " : ""
        def filterLabel = item.value.displayName.replaceFirst(/^\-/, "") // remove leading "-" for exclude searches
        def mb = new MarkupBuilder(out)

        mb.span (class: "${attrs.cssClass} tooltips active-filters__filter") {
            span(class: "active-filters__label") {
                if (item.key.contains("occurrence_year")) {
                    filterLabel = prefix + filterLabel
                        .replaceAll(':', ': ')
                        .replaceAll(
                            'occurrence_year',
                            alatag.message(code: 'facet.occurrence_year', default: 'occurrence_year')
                        )

                    mkp.yieldUnescaped(filterLabel.replaceAll(/(\d{4})\-.*?Z/) { all, year ->
                        def year10 = year?.toInteger() + 10

                        "${year} - ${year10}"
                    })
                } else {
                    // We can't translate it before it gets here, so although ugly, this will have to do.
                    def facet = filterLabel.split(":")[0]
                    def label = prefix + alatag.message(code: "facet.${item.key}", default: facet)
                    def values = item.value.value.split(" OR ${item.key}:").join(", ")

                    mkp.yieldUnescaped("${label}: ${values}")
                }
            }

            span(
                class: "fa fa-close active-filters__close-button",
                "data-facet": item.key,
                "onClick": "removeFacet(this); return false;"
            ) {
                // MarkupBuilder doesn't close tags if content is empty
                mkp.yield('')
            }
        }
    }

    /**
     *  Generate facet links in the left hand column
     *
     *  @attr facetResult REQUIRED
     *  @attr queryParam REQUIRED
     *  @attr fieldDisplayName REQUIRED
     */
    def facetLinkList = { attrs ->
        def facetResult = attrs.facetResult
        def queryParam = attrs.queryParam
        def fieldName = facetResult.fieldName
        def fieldDisplayName = attrs.fieldDisplayName
        def mb = new MarkupBuilder(out)
        def linkTitle = g.message(code: 'facets.results.filterBy', args: [fieldDisplayName])

        def addCounts = { count ->
            mb.span(class: "facetCount") {
                mkp.yieldUnescaped(" (")
                mkp.yield(g.formatNumber(number: "${count}", format: "#,###,###"))
                mkp.yieldUnescaped(")")
            }
        }

        def lastEl = facetResult.fieldResult.last()

        if (lastEl.label == 'before') {
            // range facets have the "before" special fq element at end - move it to the front of array
            facetResult.fieldResult.pop()
            facetResult.fieldResult.putAt(0, lastEl)
        }

        mb.ul(class: 'facets nano-content erk-ulist') {
            facetResult.fieldResult.each { fieldResult ->

                if(fieldResult.count > 0) {
                    // Catch specific facets fields
                    if(fieldResult.fq) {
                        // biocache-service has provided a fq field in the fieldResults list
                        li(class: 'erk-ulist__item') {
                            a(href: "?${queryParam}&fq=${fieldResult.fq?.encodeAsURL()}",
                                    class: "tooltips",
                                    title: linkTitle
                            ) {
                                span(class: "fa fa-square-o") {
                                    mkp.yieldUnescaped("&nbsp;")
                                }
                                span(class: "facet-item") {
                                    if(fieldResult.label) {
                                        // Get translated facet value. If there's no match, default to the value itself.
                                        mkp.yield(alatag.message(code: "facet.${fieldName}.${fieldResult.label}", default: fieldResult.label))
                                    } else {
                                        mkp.yield(alatag.message(code: "facet.absent"))
                                    }

                                    addCounts(fieldResult.count)
                                }

                            }

                        }
                    } else if (facetResult.fieldName.startsWith("occurrence_") && facetResult.fieldResult && facetResult.fieldResult.size() > 1) {
                        // decade date range a special case
                        def decade = processDecadeLabel(facetResult.fieldName, facetResult.fieldResult?.get(1)?.label, fieldResult.label)

                        li(class: 'erk-ulist__item') {
                            a(href: "?${queryParam}&fq=${decade.fq}",
                                    class: "tooltips",
                                    title: linkTitle
                            ) {
                                span(class: "fa fa-square-o") {
                                    mkp.yieldUnescaped("&nbsp;")
                                }
                                span(class: "facet-item") {
                                    mkp.yieldUnescaped("${decade.label}")
                                    addCounts(fieldResult.count)
                                }
                            }

                        }
                    } else {
                        def label = alatag.message(code: "${facetResult.fieldName}.${fieldResult.label}") ?: alatag.message(code: fieldResult.label)
                        def href = "?${queryParam}&fq=${facetResult.fieldName}:"
                        if (isRangeFilter(fieldResult.label)) {
                            href += "${fieldResult.label?.encodeAsURL()}"
                        } else {
                            href += "%22${fieldResult.label?.encodeAsURL()}%22"
                        }
                        li(class: 'erk-ulist__item') {
                            a(href: href,
                                    class: "tooltips",
                                    title: linkTitle
                            ) {
                                span(class: "fa fa-square-o") {
                                    mkp.yieldUnescaped("&nbsp;")
                                }
                                span(class: "facet-item") {
                                    mkp.yield(label)
                                    addCounts(fieldResult.count)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private Boolean isRangeFilter(fqValue){
        rangePattern.matcher(fqValue).matches()
    }

    /**
     * Process decade labels
     *
     * @param fieldName
     * @param firstLabel
     * @param fqLabel
     * @return
     */
    private Map processDecadeLabel(String fieldName, String firstLabel, String fqLabel) {
        Map output = [:]

        if (fqLabel.toLowerCase() == "before") {
            output.startDate = "*"
            output.startYear = "Before "
            output.endDate = firstLabel
            output.endYear = output.endDate?.substring(0, 4)
        } else if(fqLabel && fqLabel.length() >= 4) {
            output.startDate = fqLabel
            output.startYear = fqLabel.substring(0, 4)
            output.endDate = fqLabel.replace('0-01-01T00:00:00Z','9-12-31T11:59:59Z')
            output.endYear = " - " + output.endDate.substring(0, 4)
        }
        output.fq = "${fieldName}:[${output.startDate} TO ${output.endDate}]"
        output.label = "${output.startYear} ${output.endYear}"

        output
    }

    /**
     * Determine the recordId TODO
     *
     * @attr record REQUIRED the record object (JsonObject)
     * @attr skin
     */
    def getRecordId = { attrs ->
        def record = attrs.record ?: null
        def catalogNumber = record.raw.occurrence.catalogNumber

        if (catalogNumber) {
            out << catalogNumber
        } else {
            out << record.raw.occurrence.occurrenceID
        }
    }

    /**
     * Determine the scientific name
     *
     * @attr record REQUIRED the record object (JsonObject)
     */
    def getScientificName = { attrs ->
        def record = attrs.record
        def sciName = ""

        if (record.processed.classification.scientificName) {
            sciName = record.processed.classification.scientificName
        } else if (record.raw.classification.scientificName) {
            sciName = record.raw.classification.scientificName
        } else {
            sciName = "${record.raw.classification.genus} ${record.raw.classification.specificEpithet}"
        }
        out << sciName
    }

    /**
     * Print a <li> for user assertions on occurrence record page
     *
     * @attr groupedAssertions REQUIRED
     */
    def groupedAssertions = { attrs ->
        List groupedAssertions = attrs.groupedAssertions
        def mb = new MarkupBuilder(out)

        groupedAssertions.each { assertion ->

            mb.li(id: assertion?.usersAssertionUuid) {
                mkp.yield(alatag.message(code: "${assertion.name}", default: "${assertion.name}"))

                if (assertion.assertionByUser) {
                    br()
                    strong() {
                        mkp.yield(" (added by you")
                        if (assertion.users?.size() > 1) {
                            mkp.yield(" and ${assertion.users.size() - 1} other user${(assertion.users.size() > 2) ? 's' : ''})")
                        } else {
                            mkp.yield(")")
                        }
                    }
                } else {
                    mkp.yield(" (added by ${assertion.users?.size()} user${(assertion.users?.size() > 1) ? 's' : ''})")
                }
            }
        }
    }

    /**
     * Generate the icon and popup for the data quality help codes/links
     *
     * @attr code REQUIRED
     */
    def dataQualityHelp = { attrs ->
        def mb = new MarkupBuilder(out)
        mb.a(
                href: "#",
                class: "dataQualityHelpLink",
                "data-toggle": "popover",
                "data-code": attrs.code ?: ""
        ) {
            i(class: "icon-question-sign", "")
        }
        //def html = "&nbsp;<a href='#' class='dataQualityHelpLink' data-toggle='popover' data-code='${code}'><i class='icon-question-sign'></i></a>"
        //out << html
    }

    /**
     * Generate the table body for the raw vs processed table (popup)
     *
     * @attr map REQUIRED
     */
    def formatRawVsProcessed = { attrs ->
        def map = attrs.map
        def mb = new MarkupBuilder(out)

        map.each { group ->
            if (group.value) {
                group.value.eachWithIndex() { field, i ->
                    mb.tr() {
                        if (i == 0) {
                            td(class: "noStripe", rowspan: "${group.value.length()}") {
                                b(group.key)
                            }
                        }
                        td(alatag.camelCaseToHuman(text: field.name))
                        td(field.raw, class: "compare-table__cell--break")
                        td(field.processed, class: "compare-table__cell--break")
                    }
                }
            }
        }
    }

    /**
     * Camel case converted, taken from JS code:
     *
     * str.replace(/([a-z])([A-Z])/g, "$1 $2").toLowerCase().capitalize();
     *
     * @attr text REQUIRED the input text
     */
    def camelCaseToHuman = { attrs ->
        String text = attrs.text
        text = text.replaceAll(/([a-z])([A-Z])/, '$1 $2').toLowerCase().capitalize()
        out << text.replaceAll("_", " ")
    }

    /**
     * Generate an occurrence table row
     *
     * @attr fieldName REQUIRED
     * @attr fieldNameIsMsgCode
     * @attr fieldCode
     * @attr section REQUIRED
     * @attr annotate REQUIRED
     * @attr path
     * @attr guid
     * @attr idExtension
     */
    def occurrenceTableRow = { attrs, body ->
        String bodyText = (String) body()
        def guid = attrs.guid
        def path = attrs.path
        def fieldCode = attrs.fieldCode
        def fieldName = attrs.fieldName
        def fieldNameIsMsgCode = attrs.fieldNameIsMsgCode
        // prevent duplicate IDs in case the field is put out both as main row and DWC extra
        def idExtension = attrs.idExtension
        def userDetails

        if (StringUtils.isNotBlank(bodyText)) {
            def link = (guid) ? "${path}${guid}" : ""
            def mb = new MarkupBuilder(out)
            def nodeId = (idExtension) ? "${fieldCode}-${idExtension}" : "${fieldCode}"

            mb.tr(id: nodeId) {
                td(class: "dwcLabel") {
                    if (fieldNameIsMsgCode) {
                        mkp.yield(alatag.message(code: "${fieldName}"))
                    } else {
                        mkp.yieldUnescaped(formatFieldName(fieldName))
                    }
                }
                td(class: "value") {
                    if (link) {
                        a(href: link) {
                            mkp.yieldUnescaped(bodyText)
                        }
                    } else {
                        mkp.yieldUnescaped(bodyText)
                    }
                }
            }
        }
    }

    /**
     * Generate a compare record "row"
     *
     * @attr compareRecord REQUIRED
     * @attr fieldsMap REQUIRED
     * @attr group REQUIRED
     * @attr exclude REQUIRED
     */
    def formatExtraDwC = { attrs ->
        def compareRecord = attrs.compareRecord
        Map fieldsMap = attrs.fieldsMap
        def group = attrs.group
        def exclude = attrs.exclude ?: ''
        def output = ""

        compareRecord.get(group).each { cr ->
            def key = cr.name
            def label = alatag.message(code: "recordcore.dynamic.${key}", default: "${key}") ?: alatag.camelCaseToHuman(text: key) ?: StringUtils.capitalize(key)
            // only output fields not already included (by checking fieldsMap Map) && not in excluded list
            if (!fieldsMap.containsKey(key) && !StringUtils.containsIgnoreCase(exclude, key)) {
                def tagBody

                if (cr.processed && cr.raw && cr.processed == cr.raw) {
                    tagBody = cr.processed
                } else if (!cr.raw && cr.processed) {
                    tagBody = cr.processed
                } else if (cr.raw && !cr.processed) {
                    tagBody = cr.raw
                } else {
                    tagBody = """
                        ${cr.processed}
                        <br />
                        <span class="originalValue">
                            ${g.message(code: 'recordcore.label.suppliedas')} "${cr.raw}"
                        </span>
                    """
                }
                output += alatag.occurrenceTableRow(annotate: "true", section: "dataset", fieldCode: "${key}", fieldName: "<span class='dwc'>${label}</span>", idExtension: "-extra-dwc") {
                    tagBody
                }
            }
        }
        out << output
    }

    def formatDynamicLabel(str){
        if(str){
           str.substring(0, str.length() - 2).replaceAll("_", " ")
        } else {
            str
        }
    }

    /**
     * Returns column name with row_ prefix, if a name without said prefix has
     * not been found.
     *
     * @attr columns REQUIRED
     * @attr allColumns REQUIRED
     * @return array of column names
     */
    def getColumnsNames = { columns, allColumns ->
        def parsedColumns = []

        columns.each { column ->
            def rawKey = "raw_" + column

            if(allColumns.contains(column)) {
                parsedColumns.push(column)
            } else if(allColumns.contains(rawKey)) {
                parsedColumns.push(rawKey)
            }
        }

        return parsedColumns
    }

    /**
     * Format and build HTML for occurrence properties.
     *
     * @attr occurrence REQUIRED
     * @attr key REQUIRED
     * @attr builder REQUIRED
     */

    def formatCell = { builder, properties, occurrence, key ->
        def value = occurrence.get(key, "")
        def style = 'search-results-cell'

        if(key == 'eventDate') {
            def formatted = ""
            if(!occurrence.assertions.contains("incompleteCollectionDate")) {
                formatted = g.formatDate(date: new Date(value), format: "yyyy-MM-dd")
            } else if(occurrence.year || occurrence.month) {
                formatted += occurrence.get("year", "0000")
                if(occurrence.month) {
                    formatted += "-"
                    formatted += occurrence.get("month", "00")
                }
            }

            builder.td(class: "${style} search-results-cell--date", title: formatted, *:properties, formatted)
        } else if(key == 'collectors' && value.size() > 2) {
            def formatted = value[0..1].join(', ') + ', ...'

            builder.td(class: style, title: formatted, *:properties, formatted)
        } else if(key == 'collectors') {
            def formatted = value[0..-1].join(', ')

            builder.td(class: style, title: formatted, *:properties, formatted)
        } else if(key == 'scientificName' || key == 'raw_scientificName') {
            def formatted = value ? value : g.message(code: 'listtable.viewRecord')

            builder.td(class: "${style} search-results-cell--taxon", title: formatted, *:properties) {
                a(
                    href: g.createLink(url: "${request.contextPath}/occurrences/${occurrence.uuid}"),
                    title: value,
                    formatted
                )
            }
        } else if(key == 'multimedia') {
            builder.td(class: "${style} search-results-cell--multimedia", *:properties) {
                value.each { type ->
                    if(type == 'Image') {
                        // We are going to set up image icons that will be built into Lightbox thumbnails by javascript.
                        // To avoid waste data stored in these nodes, we'll set up only occurrence properties that will
                        // be needed for creating thumbnails.
                        def truncatedOccurrence = new groovy.json.JsonBuilder({
                            'uuid' occurrence.uuid
                            'largeImageUrl' occurrence.largeImageUrl
                            'raw_scientificName' occurrence.raw_scientificName
                            'image' occurrence.image
                            'smallImageUrl' occurrence.smallImageUrl
                            'typeStatus' occurrence.typeStatus
                            'institutionName' occurrence.institutionName
                            'collector' occurrence.collector
                            'eventDate' occurrence.eventDate
                            'dataResourceName' occurrence.dataResourceName
                        })

                        span(
                            class: 'fa fa-image thumbnail-anchor', // This will become a thumbnail.
                            title: g.message(code: 'listtable.hasImage'),
                            *:['data-occurrence': truncatedOccurrence],
                            '' // MarkupBuilder doesn't close tags if their content is absent. So, we give it content.
                        )
                    } else if(type == 'Sound') {
                        span(class: 'fa fa-music', title: g.message(code: 'listtable.hasSound'))
                    } else if(type == 'Video') {
                        span(class: 'fa fa-video-camera', title: g.message(code: 'listtable.hasVideo'))
                    }
                }
            }
        } else if(key == 'individualCount') {
            builder.td(class: "${style} search-results-cell--count", *:properties, title: value, value)
        } else if(key == 'locality') {
            def contentParts = [ occurrence.municipality, occurrence.locality ]
            def tooltipParts = [ occurrence.country, occurrence.municipality, occurrence.locality ]

            contentParts.removeAll([null])
            tooltipParts.removeAll([null])

            // In case we have only country, don't hide it in content.
            if(contentParts.size() == 0) {
                contentParts = tooltipParts;
            }

            def formattedContent = contentParts.join(', ')
            def formattedTooltip = tooltipParts.join(', ')

            builder.td(class: style, title: formattedTooltip, *:properties, formattedContent)
        } else if(key == "speciesListUid") {
            def listNames = []
            value.each { listUid ->
                def listName = g.message(message: "listtable.specieslist.${listUid}")
                if (listName) {
                    listNames.push(listName)
                }
            }
            def formatted = listNames[0..-1].join(', ')
            builder.td(class: style, title: formatted, *:properties, formatted)
        } else {
            builder.td(class: style, title: value, *:properties, value)
        }
    }

    /**
     * Outputs occurrences table (HTML) to the search page.
     *
     * @attr occurrences REQUIRED
     */
    def formatOccurrencesTable = { attrs ->
        def occurrences = attrs.occurrences
        def mb = new MarkupBuilder(out)
        def allColumns = []

        occurrences.toArray().each {
            it.names().each {
                if(!allColumns.contains(it)) {
                    allColumns.push(it)
                }
            }
        }

        def normalColumns = getColumnsNames(
            grailsApplication.config.table.columns,
            allColumns
        )

        def priorityColumns = getColumnsNames(
            grailsApplication.config.table.priorityColumns,
            allColumns
        )

        // Table header.
        mb.thead() {
            tr(class: 'search-results-row') {
                normalColumns.each { column ->
                    def properties = ['data-priority-col': priorityColumns.contains(column)]
                    def styleClass = 'search-results-header'

                    if(column == 'individualCount') {
                        styleClass += ' search-results-cell--count'
                    }

                    if(column == 'eventDate') {
                        styleClass += ' search-results-cell--date'
                    }

                    th(class: styleClass, *:properties) {
                        mkp.yieldUnescaped(g.message(code: "listtable.${column}"))
                    }
                }
            }
        }

        // Table body.
        mb.tbody() {
            occurrences.toArray().each { occurrence ->
                tr(class: 'search-results-row') {
                    normalColumns.each { column ->
                        def properties = ['data-priority-col': priorityColumns.contains(column)]

                        try {
                            formatCell(mb, properties, occurrence, column)
                        } catch(Exception e) {
                            td(class: 'search-results-cell', '')
                        }
                    }
                }
            }
        }
    }

    /**
     * Alternative to g.message(code: 'foo.bar')
     *
     * @see org.codehaus.groovy.grails.plugins.web.taglib.ValidationTagLib
     *
     * @attr code REQUIRED
     * @attr default
     */
    def message = { attrs ->
        def code = attrs.code?.toString() // in case a G-sting
        def output = ""

        if (code) {
            String defaultMessage
            if (attrs.containsKey('default')) {
                defaultMessage = attrs['default']?.toString()
            } else {
                defaultMessage = code
            }

            Map messagesMap = messageSourceCacheService.getMessagesMap(RequestContextUtils.getLocale(request)) // g.message too slow so we use a Map instead
            def message = messagesMap.get(code)
            output = message ?: defaultMessage
        }

        return output
    }

    /**
     * Display the logged in user (user id)
     */
    def loggedInUserId = { attrs ->
        out << authService?.userId
    }

    /**
     * Display the logged in user (display name)
     */
    def loggedInUserDisplayname = { attrs ->
        out << (authService?.displayName ?: authService?.email)
    }

    /**
     * Display the logged in user (email)
     */
    def loggedInUserEmail = { attrs ->
        out << authService?.email
    }

    /**
     * Get the list of available reason codes and labels from the Logger app
     *
     * Note: outputs an Object and thus needs:
     *
     *   static returnObjectForTags = ['getLoggerReasons']
     *
     * at top of taglib
     */
    def getLoggerReasons = { attrs ->
        webServicesService.getLoggerReasons()
    }

    /**
     * Get the appropriate sourceId for the current hub
     */
    def getSourceId = { attrs ->
        def skin = grailsApplication.config.skin.layout?.toUpperCase()
        def sources = webServicesService.getLoggerSources()
        sources.each {
            if (it.name == skin) {
                out << it.id
            }
        }
    }

    /**
     * Display an outage banner
     */
    def outageBanner = { attrs ->
        def message = "Outage banner no longer supported - please use ala-admin-plugin tag - <code>&lt;ala:systemMessage/&gt;</code> and remove <code>&lt;alatag:outageBanner/&gt;</code>"

        if (message) {
            out << "<div id='outageMessage'>" + message + "</div>"
        }
    }

    /**
     *
     * @attr msg REQUIRED
     * @attr level
     */
    def logMsg = { attrs ->
        log."${attrs.level ?: 'info'}" attrs.msg
    }

    /**
     * Determine the URL prefix for biocache-service AJAX calls. Looks at the
     * biocache.ajax.useProxy config var to see whether or not to use the proxy
     */
    def getBiocacheAjaxUrl = { attrs ->
        String url = grailsApplication.config.biocache.baseUrl
        Boolean useProxy = grailsApplication.config.biocache.ajax.useProxy.toBoolean() // will convert String 'true' to boolean true
        log.debug "useProxy = ${useProxy}"

        if (useProxy) {
            url = g.createLink(uri: '/proxy')
        }

        out << url
    }

    /**
     * Generate a query string for the remove spatial filter link
     */
    def getQueryStringForWktRemove = { attr ->
        def paramsCopy = params.clone()
        paramsCopy.remove("wkt")
        paramsCopy.remove("action")
        paramsCopy.remove("controller")
        def queryString = WebUtils.toQueryString(paramsCopy)
        out << queryString
    }

    def getQueryStringForRadiusRemove = { attr ->
        def paramsCopy = params.clone()
        paramsCopy.remove("lat")
        paramsCopy.remove("lon")
        paramsCopy.remove("radius")
        paramsCopy.remove("action")
        paramsCopy.remove("controller")
        def queryString = WebUtils.toQueryString(paramsCopy)
        out << queryString
    }

    /**
     * Output the meta tags (HTML head section) for the build meta data in application.properties
     * E.g.
     * <meta name="svn.revision" content="${g.meta(name: 'svn.revision')}" />
     * etc.
     *
     * Updated to use properties provided by build-info plugin
     */
    def addApplicationMetaTags = { attrs ->
        // def metaList = ['svn.revision', 'svn.url', 'java.version', 'java.name', 'build.hostname', 'app.version', 'app.build']
        def metaList = ['app.version', 'app.grails.version', 'build.date', 'scm.version', 'environment.BUILD_NUMBER', 'environment.BUILD_ID', 'environment.BUILD_TAG', 'environment.GIT_BRANCH', 'environment.GIT_COMMIT']
        def mb = new MarkupBuilder(out)

        mb.meta(name: 'grails.env', content: "${Environment.current}")
        metaList.each {
            mb.meta(name: it, content: g.meta(name: it))
        }
        mb.meta(name: 'java.version', content: "${System.getProperty('java.version')}")
    }

    /**
     * A little bit of email scrambling for dumb scrappers.
     *
     * Uses email attribute as email if present else uses the body.
     * If no attribute and the body is not an email address then nothing is shown.
     *
     * @attrs email the address to decorate
     * @body the text to use as the link text
     */
    def emailLink = { attrs, body ->
        def strEncodedAtSign = "(SPAM_MAIL@ALA.ORG.AU)"
        String email = attrs.email
        if (!email)
            email = body().toString()
        int index = email.indexOf('@')
        if (index > 0) {
            email = email.replaceAll("@", strEncodedAtSign)
            out << "<a href='#' class='link under' onclick=\"return sendEmail('${email}')\">${body()}</a>"
        }
    }
}
