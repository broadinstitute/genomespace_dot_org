module GuidesHelper

	def support_guides_url(guide)
		return "/support/guides/" + guide.url
	end
	
	def recipes_url
		support_guides_url(Guide.find_by_title("Recipes"))
	end

end
