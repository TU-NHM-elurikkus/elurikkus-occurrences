<%@ page import="org.springframework.web.servlet.support.RequestContextUtils" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

        <alatag:addApplicationMetaTags />

        <g:render template="/manifest" plugin="elurikkus-commons" />
        <g:render template="/layouts/global" />

        <title>
            <g:layoutTitle />
        </title>

        <g:javascript>
            var BC_CONF = {
                biocacheServiceUrl: "${alatag.getBiocacheAjaxUrl()}",
                bieWebappUrl: "${grailsApplication.config.bie.ui.url}",
                collectoryUrl: "${grailsApplication.config.collectory.ui.url}",
                contextPath: "${request.contextPath}",
                locale: "${RequestContextUtils.getLocale(request)}",
                queryContext: "${grailsApplication.config.biocache.queryContext}",
                bieIndexUrl: "${grailsApplication.config.bieService.ui.url}"
            };
        </g:javascript>

        <script src="https://maps.googleapis.com/maps/api/js?v=3.41&key=${grailsApplication.config.google.apikey}" type="text/javascript"></script>

        <asset:stylesheet src="occurrences.css" />
        <asset:javascript src="occurrences.js" />

        <g:layoutHead />
    </head>

    <body>
        <g:render template="/menu" plugin="elurikkus-commons" />

        <div>
            <g:layoutBody />
        </div>

        <g:render template="/footer" plugin="elurikkus-commons" />
    </body>
</html>
