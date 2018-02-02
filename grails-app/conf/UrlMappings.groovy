class UrlMappings {

	static mappings = {
        "/explore/your-area"(controller: "explore", action: "area")

        "/$controller/$action?/$id?(.$format)?" {
            constraints {
                // apply constraints here
            }
        }

        "500"(view: "/error")
	}
}
