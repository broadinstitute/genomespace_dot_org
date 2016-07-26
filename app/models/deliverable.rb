class Deliverable < ActiveRecord::Base

	attr_accessible :description, :completed, :created_at, :updated_at, :quarter, 
									:approval_comments, :approved_by, :identifier, :tech, :delta, :lock_version, :artifact_attributes

	has_one :artifact, :dependent => :destroy
	
	validates_presence_of  :description, :quarter

	accepts_nested_attributes_for :artifact, :allow_destroy => true
	
	def self.admin_description
		return "Deliverables objects that represent line items from the GenomeSpace grant that we are responsible for creating on a quarterly basis.  Each deliverable can have one or more \"artifacts\" that represent work done to satisfy that deliverable."
	end
end
