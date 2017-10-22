<%@ page import="grails.util.Environment" %>

<script type="text/javascript">
    var OCCURRENCES_CONF = {
        contextPath: "${request.contextPath}",
        locale: "${(org.springframework.web.servlet.support.RequestContextUtils.getLocale(request).toString())?:request.locale}"
    };

    var GRAILS_APP = {
        environment: "${Environment.current.name}",
        rollbarApiKey: "${grailsApplication.config.rollbar.postApiKey}"
    };
</script>
