ThinkingSphinx::Index.define :page, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :title, as: :page_title
	indexes :url, as: :page_url
	indexes :content, as: :page_content
	indexes :created_by, as: :page_created_by
	indexes :desc, as: :page_desc
	indexes :category, as: :page_category
	
	has :id, :as => :page_id
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end