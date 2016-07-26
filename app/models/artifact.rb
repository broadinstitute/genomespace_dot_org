class Artifact < ActiveRecord::Base

	attr_accessible :deliverable_id, :contents, :created_at, :updated_at
	
	belongs_to :deliverable
	
	before_save :fix_ckeditor_attachment_paths
	
	after_save :set_deliverable_delta_flag
	
	private
	
	# to fix bug with hrefs not being saved correctly
	def fix_ckeditor_attachment_paths
	  if self.contents.include?("_cke_saved_href")
	  	self.contents.gsub!(/href=\"javascript:void\(0\)\/\*\d+\*\/\"/, '')
	  	self.contents.gsub!(/_cke_saved_href/, 'href')
	  end
	end
	
	def set_deliverable_delta_flag
		deliverable.delta = true
		deliverable.save
	end
end
