<g:if test="${record.raw.occurrence.photographer || image.metadata?.creator}">
    <cite>
        <g:message code="show.sidebar.image.creator" />: ${record.raw.occurrence.photographer ?: image.metadata?.creator}
    </cite>

    <br />
</g:if>

<g:if test="${record.raw.occurrence.rights || image.metadata?.rights}">
    <cite>
        <g:message code="recordcore.dataset.rights" />: ${record.raw.occurrence.rights ?: image.metadata?.rights}
    </cite>

    <br />
</g:if>

<g:if test="${record.raw.occurrence.rightsholder || image.metadata?.rightsholder}">
    <cite>
        <g:message code="recordcore.dynamic.rightsholder" />: ${record.raw.occurrence.rightsholder ?: image.metadata?.rightsholder}
    </cite>

    <br />
</g:if>

<g:if test="${record.raw.miscProperties.rightsHolder}">
    <cite>
        <g:message code="recordcore.dynamic.rightsholder" />: ${record.raw.miscProperties.rightsHolder}
    </cite>

    <br />
</g:if>

<g:if test="${image.metadata?.license}">
    <cite>
        <g:message code="recordcore.dynamic.license" />: ${image.metadata?.license}
    </cite>

    <br />
</g:if>

<g:if test="${grailsApplication.config.skin.useAlaImageService.toBoolean()}">
    <a href="${grailsApplication.config.images.metadataUrl}${image.filePath}" target="_blank">
        <g:message code="show.sidebar.occurrenceimages.navigator01" />
    </a>
</g:if>
<g:else>
    <a href="${image.alternativeFormats.imageUrl}" target="_blank">
        <g:message code="show.sidebar.occurrenceimages.navigator02" />
    </a>
</g:else>
