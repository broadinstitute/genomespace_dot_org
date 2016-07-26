ThinkingSphinx::Index.define :post, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :title, as: :post_title
	indexes :content, as: :post_content
	indexes :url, as: :post_url
	indexes :author, as: :post_author
	
	has :id, :as => :post_id

	set_property :enable_star => 1
	set_property :min_infix_len => 3

end