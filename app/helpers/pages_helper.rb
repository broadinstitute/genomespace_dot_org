module PagesHelper

	def genomespace_url(page)
	
		if Page.find(page.id).version > page.version 
			return "/" + page.url + "?rev=" + page.version
		else
			return "/" + page.url
		end
	end
end
