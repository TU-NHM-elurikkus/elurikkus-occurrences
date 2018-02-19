import grails.util.Environment
// from /commons/lib/
import com.nextdoor.rollbar.RollbarLog4jAppender

grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

default_config = "/data/${appName}/config/${appName}-config.properties"
commons_config = "/data/commons/config/commons-config.properties"

grails.config.locations = [
    "file:${commons_config}",
    "file:${default_config}"
]

def prop = new Properties()
def rollbarServerKey = ""

// Load rollbar key from commons config file.
try {
    File fileLocation = new File(commons_config)
    prop.load(new FileInputStream(fileLocation))
    rollbarServerKey = prop.getProperty("rollbar.postServerKey") ?: ""
} catch(IOException e) {
    // e.printStackTrace()
}

if(!new File(default_config).exists()) {
    println "ERROR - [${appName}] No external configuration file defined. ${default_config}"
}
if(!new File(commons_config).exists()) {
    println "ERROR - [${appName}] No external commons configuration file defined. ${commons_config}"
}
if(rollbarServerKey.isEmpty()) {
    println "ERROR - [${appName}] No Rollbar key."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

/******************************************************************************\
 *  SKINNING
\******************************************************************************/
skin.layout = "eElurikkus"
skin.orgNameLong = "Occurrence browser"
skin.orgNameShort = "Occurrences"
// whether crumb trail should include a home link that is external to this webabpp - ala.baseUrl is used if true
skin.includeBaseUrl = true
skin.headerUrl = "classpath:resources/generic-header.jsp" // can be external URL
skin.footerUrl = "classpath:resources/generic-footer.jsp" // can be external URL
skin.fluidLayout = true // true or false
chartsBgColour = "#FFFFFF"

facets.defaultSelected = ""

/******************************************************************************\
 *  MISC
\******************************************************************************/


// The ACCEPT header will not be used for content negotiation for user agents containing the following strings (defaults to the 4 major rendering engines)
grails.mime.disable.accept.header.userAgents = ["Gecko", "WebKit", "Presto", "Trident"]
grails.mime.types = [ // the first one is the default format
    all:           "*/*", // "all" maps to "*" or the first available format in withFormat
    atom:          "application/atom+xml",
    css:           "text/css",
    csv:           "text/csv",
    form:          "application/x-www-form-urlencoded",
    html:          ["text/html","application/xhtml+xml"],
    js:            "text/javascript",
    json:          ["application/json", "text/json"],
    multipartForm: "multipart/form-data",
    rss:           "application/rss+xml",
    text:          "text/plain",
    hal:           ["application/hal+json","application/hal+xml"],
    xml:           ["text/xml", "application/xml"]
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// Legacy setting for codec used to encode data with ${}
grails.views.default.codec = "html"

// The default scope for controllers. May be prototype, session or singleton.
// If unspecified, controllers are prototype scoped.
grails.controllers.defaultScope = "singleton"

// GSP settings
grails {
    views {
        gsp {
            encoding = "UTF-8"
            htmlcodec = "xml" // use xml escaping instead of HTML4 escaping
            codecs {
                expression = "html" // escapes values inside ${}
                scriptlet = "html" // escapes output from scriptlets in GSPs
                taglib = "none" // escapes output from taglibs
                staticparts = "none" // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //"text/html" = "html"
        }
    }
}

grails.converters.encoding = "UTF-8"
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = "Instance"

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ["password"]

// configure auto-caching of queries by default (if false you can cache individual queries with "cache: true")
grails.hibernate.cache.queries = false


def logging_dir = System.getProperty("catalina.base") ? System.getProperty("catalina.base") + "/logs" : "/var/log/tomcat7"
if(!new File(logging_dir).exists()) {
    logging_dir = "/tmp"
}

println "INFO - [${appName}] logging_dir: ${logging_dir}"

log4j = {
    def logPattern = pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")

    def rollbarAppender = new RollbarLog4jAppender(
        name: "rollbar",
        layout: logPattern,
        threshold: org.apache.log4j.Level.ERROR,
        environment: Environment.current.name,
        accessToken: rollbarServerKey
    )

    def tomcatLogAppender = rollingFile(
        name: "tomcatLog",
        maxFileSize: "10MB",
        file: "${logging_dir}/occurrences.log",
        threshold: org.apache.log4j.Level.WARN,
        layout: logPattern
    )

    appenders {
        environments {
            production {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            test {
                appender(tomcatLogAppender)
                appender(rollbarAppender)
            }
            development {
                console(
                    name: "stdout",
                    layout: logPattern,
                    threshold: org.apache.log4j.Level.DEBUG)
            }
        }
    }

    root {
        error "tomcatLog", "rollbar"
        warn "tomcatLog"
        info "stdout"
    }

    error  "org.codehaus.groovy.grails.web.servlet",        // controllers
           "org.codehaus.groovy.grails.web.pages",          // GSP
           "org.codehaus.groovy.grails.web.sitemesh",       // layouts
           "org.codehaus.groovy.grails.web.mapping.filter", // URL mapping
           "org.codehaus.groovy.grails.web.mapping",        // URL mapping
           "org.codehaus.groovy.grails.commons",            // core / classloading
           "org.codehaus.groovy.grails.plugins",            // plugins
           "org.codehaus.groovy.grails.orm.hibernate",      // hibernate integration
           "org.springframework",
           "org.hibernate",
           "net.sf.ehcache.hibernate"
    info   "grails.app"
    debug  "grails.app.controllers",
           "grails.app.services",
           //"grails.app.taglib",
           "grails.web.pages",
           //"grails.app",
           "au.org.ala.cas",
           "au.org.ala.biocache.hubs",
           "au.org.ala.biocache.hubs.OccurrenceTagLib"
}

/******************************************************************************\
 * SEARCH RESULTS
\******************************************************************************/
// Table columns and order
table.columns = [
    "eventDate", "scientificName", "vernacularName", "individualCount", "sex", "behavior", "lifeStage", "catalogNumber",
    "locality", "collectors", "multimedia", "basisOfRecord", "institutionName", "dataResourceName"
]

// Table columns that will not be hidden
table.priorityColumns = ["eventDate" , "scientificName"]
