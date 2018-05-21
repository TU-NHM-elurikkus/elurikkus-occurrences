<div>
    <g:if test="${mediaObj.metadata?.title}">
        <b>
            ${mediaObj.metadata?.title}
            <br />
        </b>
    </g:if>
    <g:if test="${mediaObj.metadata?.license}">
        <span>
            <b>
                <g:message code="recordcore.dynamic.license" />:
            </b>
            ${mediaObj.metadata?.license}
            <br />
        </span>
    </g:if>
    <g:if test="${mediaObj.metadata?.rightsHolder}">
        <span>
            <b>
                <g:message code="recordcore.dynamic.rightsholder" />:
            </b>
            ${mediaObj.metadata?.rightsHolder}
            <br />
        </span>
    </g:if>
    <g:if test="${mediaObj.metadata?.creator}">
        <span>
            <b>
                <g:message code="media.createdBy.label" />:
            </b>
            ${mediaObj.metadata?.creator}
            <br />
        </span>
    </g:if>
</div>

<a href="${mediaObj.alternativeFormats.imageUrl}" target="_blank">
    <g:message code="show.sidebar.occurrenceimages.navigator02" />
</a>
