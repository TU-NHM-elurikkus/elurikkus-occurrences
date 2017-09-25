<div id="contactCuratorView" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="contactCuratorViewLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="contactCuratorViewLabel">
                    <g:message code="show.contactcuratorview.title" />
                </h3>
            </div>

            <div class="modal-body">
                <p>
                    <g:message code="show.contactcuratorview.message" />
                </p>

                <g:each in="${contacts}" var="c">
                    <address>
                        <strong>
                            ${c.contact.firstName} ${c.contact.lastName}
                            <g:if test="${c.primaryContact}">
                                <span class="primaryContact">
                                    *
                                </span>
                            </g:if>
                        </strong>

                        <br />

                        ${c.role}

                        <br />

                        <g:if test="${c.contact.phone}">
                            <abbr title="${message(code: 'general.contact.phone.title')}">
                                <g:message code="general.contact.phone.abbr" />:
                            </abbr>
                            ${c.contact.phone}
                            <br />
                        </g:if>

                        <g:if test="${c.contact.email}">
                            <abbr title="${message(code: 'general.contact.email.title')}">
                                <g:message code="general.contact.email.abbr" />:
                            </abbr>

                            <alatag:emailLink email="${c.contact.email}">
                                <g:message code="show.contactcuratorview.emailtext" />
                            </alatag:emailLink>

                            <br />
                        </g:if>
                    </address>
                </g:each>

                <p>
                    <span class="primaryContact">
                        <b>
                            *
                        </b>
                    </span>
                    <g:message code="show.contactcuratorview.primarycontact" />
                </p>
            </div>

            <div class="modal-footer">
                <button class="erk-button erk-button--light float-right" data-dismiss="modal" aria-hidden="true">
                    <g:message code="general.btn.close" />
                </button>
            </div>
        </div>
    </div>
</div>
