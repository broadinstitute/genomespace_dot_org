ThinkingSphinx::Index.define :guide_section, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes title, :as => :guide_section_title
	indexes content, :as => :guide_section_content	
	indexes display_url, :as => :guide_section_display_urls
	
	has :id, :as => :guide_section_id
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end