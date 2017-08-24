<%@ page import="org.springframework.web.servlet.support.RequestContextUtils" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

        <alatag:addApplicationMetaTags />

        <g:render template="/manifest" plugin="elurikkus-commons" />

        <title>
            <g:layoutTitle />
        </title>

        <g:javascript>
            var BC_CONF = {
                biocacheServiceUrl: "${alatag.getBiocacheAjaxUrl()}",
                bieWebappUrl: "${grailsApplication.config.bie.baseUrl}",
                bieWebServiceUrl: "${grailsApplication.config.bieService.baseUrl}",
                autocompleteHints: "${grailsApplication.config.bie?.autocompleteHints?.encodeAsJson()?:'{}'}",
                contextPath: "${request.contextPath}",
                locale: "${RequestContextUtils.getLocale(request)}",
                queryContext: "${grailsApplication.config.biocache.queryContext}"
            };
        </g:javascript>

        <asset:stylesheet src="occurrences.css"/>
        <asset:javascript src="occurrences.js"/>

        <g:layoutHead />
    </head>

    <body class="${pageProperty(name:'body.class')?:'nav-collections'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">
        <g:set var="fluidLayout" value="${grailsApplication.config.skin.fluidLayout?.toBoolean()}" />

        <g:render template="/menu" plugin="elurikkus-commons" />

        <div id="main-content">
            <g:layoutBody />
        </div>

        <g:render template="/footer" plugin="elurikkus-commons" />

    </body>
</html>
