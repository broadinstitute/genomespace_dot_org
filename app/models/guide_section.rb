class GuideSection < ActiveRecord::Base

	attr_accessible :guide_id, :title, :display_order, :content, :parent_id, :created_at, :updated_at, 
									:display_url, :created_by, :delta, :lock_version, :published, :dev, :updated_by

	versioned :if => Proc.new { |guide_section| guide_section.content_changed? || guide_section.title_changed? || guide_section.display_url_changed? }

	belongs_to  :guide
	
	before_validation :create_url
	
	before_save :fix_ckeditor_attachment_paths
	
	validates_uniqueness_of :display_url, :scope => :guide_id
	
	
	def self.get_next_display_order(id)
	
		last_item = GuideSection.find_all_by_guide_id(id).size
		return last_item += 1
		
	end
	
	def last_section
		@num_sections = GuideSection.find_all_by_guide_id(self.guide_id).size
		return @num_sections >= self.display_order
	end
	
	def check_version(params, user_signed_in)
		
		if params[:rev] && user_signed_in == true
			self.revert_to(params[:rev].to_i)
			@alert = ""
		elsif params[:rev] && user_signed_in == false
			@alert = "You need to be logged in to view previous revisions of this doc.  Please <a href=\"/users/sign_in\">log in</a> first."
		end
	
		return self, @alert
	end
	
	def has_children?
		return !GuideSection.find_all_by_parent_id(self.id).blank?
	end
	
	def get_children(visibility = nil)
		if visibility == "published"
			return GuideSection.find_all_by_parent_id_and_published(self.id, true, :order => "display_order ASC")
		else
			return GuideSection.find_all_by_parent_id(self.id, :order => "display_order ASC")
		end
	end
	
	def check_nesting?
		if self.has_children?
			children = self.get_children
			children.each do |child|
				if child.has_children?
					return false
				end
			end
		end
		# returns true if guide_section is not the first section, it is not the first nested section in a group and if it is not already at the 2nd level
		return (self.display_order != 1 && !self.first_child? && !self.double_nested? && !(self.has_children? && !self.parent_id.nil?))
	end
	
	def check_denesting?
		return !self.parent_id.nil?
	end
	
	def first_child?
		children = GuideSection.find_all_by_parent_id(self.parent_id, :order => "display_order ASC")
		unless children.blank?
			return children.first.id == self.id
		else
			return false
		end
	end
	
	def double_nested?
		begin
			return !GuideSection.find(self.parent_id).parent_id.nil?
		rescue ActiveRecord::RecordNotFound => e
			return false
		end
	end
	
	def get_nesting_display
		nesting_display = ""
		unless self.parent_id.nil?
			nesting_display << "&not;&nbsp;"
			unless !self.double_nested?
				nesting_display << "&not;&nbsp;"
			end
		end
		return nesting_display
	end
	
	def get_last_live
	
		guide_section = GuideSection.find(self.id)	
		while guide_section.dev == true && guide_section.version > 1
			guide_section.revert_to(guide_section.version - 1)
		end
		return guide_section
	
	end
	
	def plain_content
		Hpricot(self.content).to_plain_text
	end
	
	private
	
	def create_url
		
		if self.display_url.blank?
			self.display_url = self.title.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
		end	
	end
	
	# to fix bug with hrefs not being saved correctly
	def fix_ckeditor_attachment_paths
	  if self.content.include?("_cke_saved_href")
	  	self.content.gsub!(/href=\"javascript:void\(0\)\/\*\d+\*\/\"/, '')
	  	self.content.gsub!(/_cke_saved_href/, 'href')
	  end
	end
end
