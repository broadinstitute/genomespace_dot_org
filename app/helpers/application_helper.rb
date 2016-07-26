module ApplicationHelper
	
	def available_actions
		@available_actions = []
		@routes = GenomespaceNew::Application.routes.routes
		@routes.each do |route|
			if route.defaults[:action] == "index" && !route.defaults[:controller].to_s.match(/ckeditor|guide_section|site/)
				@available_actions << route.defaults[:controller]
			end
		end
		return @available_actions.uniq.sort
	end
	
	def nav_menu_categories
		return [["What is GenomeSpace?", "what-is-genomespace"], ["Tools", "tools"], ["Documentation", "documentation"], ["Developers","developers"], ["Support", "support"], ["About", "about"]]
	end
	
	def all_pages
		return Page.where("published = ? AND dev = ? AND team_page = ?", true, false, false).order("title ASC")		 
	end
end