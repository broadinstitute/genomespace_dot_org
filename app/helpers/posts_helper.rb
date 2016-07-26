module PostsHelper

	def post_url(post)
	
		return "/blog/" + post.url
	end
end
