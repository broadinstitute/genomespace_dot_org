ThinkingSphinx::Index.define :highlight, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :title, as: :highlight_title
	indexes :content, as: :highlight_content
	indexes :url, as: :highlight_url
	indexes :created_by, as: :highlight_created_by
	
	has :id, :as => :highlight_id

	set_property :enable_star => 1
	set_property :min_infix_len => 3

end