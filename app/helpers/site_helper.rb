module SiteHelper

	def all_guides
		return Guide.order("title ASC")
	end
	
	def menu_pages(category)
		@menu = MenuItem.find_all_by_category(category, :order => "display_order ASC")
		@pages = []
		@menu.each {|menu| menu.guide_id.nil? ? (@pages << Page.find(menu.page_id)) : (@pages << Guide.find(menu.guide_id))}
		
		return @pages
	end
	
	def landing_page(category)
		page = Page.find_by_category_and_landing_page(category, true)
		if page.nil?
			return "#"
		else
			return genomespace_url(page)
		end
	end
	
	def edit_button(object)
		case object.class.name
		when "Page"
			@path = edit_page_path(object)
		when "Doc"
			@path = edit_doc_path(object)
		when "GuideSection"
			@path = edit_guide_guide_section_path(Guide.find(object.guide_id), object)
		when "Tool"
			@path = edit_tool_path(object)
		when "Post"
			@path = edit_post_path(object)
		when "Highlight"
			@path = edit_highlight_path(object)
		else
			return false
		end
		return (link_to "<small class=\"edit_page_button\">Edit</small>".html_safe, @path, :class => "edit_page_button_link")
	end
	
	def get_newest_content(videos)
		highlight_date = Highlight.order("updated_at").last.updated_at
		post_date = Post.find_all_by_published(true, order: "updated_at ASC").last.updated_at
		# last_video_date = Time.parse(videos.sort_by {|x| Time.parse(x["published"]["$t"])}.last["published"]["$t"])
		arr = [highlight_date, post_date]
		arr.find_index(arr.sort.last)
	end
end
