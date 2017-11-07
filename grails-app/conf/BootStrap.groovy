import org.apache.shiro.crypto.hash.Sha256Hash

import au.org.ala.biocache.hubs.User

class BootStrap {

    def grailsApplication

    def init = { servletContext ->
        // Create the admin account
        def password = "${grailsApplication.config.adminPassword}".toString()
        def user = new User(username: "elurikkus-ala", passwordHash: new Sha256Hash(password).toHex())
        user.addToPermissions("*:*")
        user.save()
    }

    def destroy = {
    }
}
