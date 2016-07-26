module ToolsHelper

	def gs_tool_url(tool)
		return "/support/tools/#{tool.lookup_name}"
	end
	
	def gs_tool_website_link(tool)
		tool_link = HelpLink.find_by_sql("SELECT * FROM help_links WHERE tool_id = #{tool.id} AND title LIKE '%Website%'").first
		return tool_link.nil? ? HelpLink.new(url: "#") : tool_link
	end

end
