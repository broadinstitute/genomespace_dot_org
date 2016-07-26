ThinkingSphinx::Index.define :guide, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :title, as: :guide_title
	indexes :desc, as: :guide_desc
	indexes :url, as: :guide_url
	
	has :id, :as => :guide_id
	has guide_sections.id, :as => :guide_section_ids
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end