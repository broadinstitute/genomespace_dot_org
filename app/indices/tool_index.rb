ThinkingSphinx::Index.define :tool, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 
	indexes :name, as: :tool_name
	indexes :desc, as: :tool_desc
	indexes help_links.title, :as => :help_link_titles
	indexes help_links.url, :as => :help_link_urls
	
	has :id, :as => :tool_id
	has help_links.id, :as => :help_links_ids
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end