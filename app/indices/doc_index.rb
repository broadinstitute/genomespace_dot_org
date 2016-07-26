ThinkingSphinx::Index.define :doc, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :component, as: :doc_component
	indexes :dev_stage, as: :doc_dev_stage
	indexes :url, as: :doc_url
	indexes :contents, as: :doc_contents
	indexes :created_by, as: :doc_created_by
	
	has :id, :as => :doc_id
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end