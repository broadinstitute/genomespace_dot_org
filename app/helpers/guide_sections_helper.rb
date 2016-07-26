module GuideSectionsHelper

	def toc_url(guide, guide_section)
		return "/support/guides/" + guide.url + "/sections/" + guide_section.display_url
	end
	
	def next_guide_section_url(guide, guide_sections, requested_section)
		return "/support/guides/#{guide.url}/sections/#{guide_sections[guide_sections.index(requested_section) + 1].display_url}"
	end
	
	def previous_guide_section_url(guide, guide_sections, requested_section)
		return "/support/guides/#{guide.url}/sections/#{guide_sections[guide_sections.index(requested_section) - 1].display_url}"
	end

end
