ThinkingSphinx::Index.define :deliverable, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do 

	indexes :description, as: :deliverable_description, :sortable => true
	indexes :quarter, as: :deliverable_quarter, :sortable => true
	indexes :identifier, as: :deliverable_identifier, :sortable => true
	indexes artifact.contents, :as => "artifact_contents", :sortable => true
	
	has :id, :as => :deliverable_id
	has artifact.id, :as => :deliverable_artifact_id
	
	set_property :enable_star => 1
	set_property :min_infix_len => 3

end