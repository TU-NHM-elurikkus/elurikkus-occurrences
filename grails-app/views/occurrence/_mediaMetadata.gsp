<g:if test="${mediaObj.metadata?.license}">
    <span class="sidebar-citation">
        <g:message code="recordcore.dynamic.license" />: ${mediaObj.metadata?.license}
        <br />
    </span>
</g:if>
<g:if test="${mediaObj.metadata?.rightsHolder}">
    <span class="sidebar-citation">
        <g:message code="recordcore.dynamic.rightsholder" />: ${mediaObj.metadata?.rightsHolder}
        <br />
    </span>
</g:if>
<g:if test="${mediaObj.metadata?.creator}">
    <span class="sidebar-citation">
        <g:message code="file.createdBy.label" />: ${mediaObj.metadata?.creator}
        <br />
    </span>
</g:if>
