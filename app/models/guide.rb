class Guide < ActiveRecord::Base

	attr_accessible :title, :desc, :created_at, :updated_at, :url, :delta, :lock_version, :category, :published
	
	has_many  :guide_sections, :dependent => :destroy
	has_one :menu_item
	
	before_validation  :create_url
	
	after_save :add_to_menu
	
	validates_uniqueness_of :url
	
	def self.admin_description
		return "Guides are containers that hold \"Guide Sections\", which are themselves html pages.  These guide sections can be reordered and nested inside the guide to create paged user guides that are navigated with an auto-generated Table of Contents on the live site.  Like pages, guide sections also have revisions that act as version control for each section."
	end
	
	def get_num_sections
		
		sections = GuideSection.find_all_by_guide_id(self.id).size
		return sections.to_s
		
	end
	
	private
	
	def create_url
		
		if self.url.blank?
			self.url = self.title.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
		end	
	end
	
	# adds the page to the corresponding menu by creating an entry in the menu_items table
	def add_to_menu
		# only creates menu item if the page has a category, is published, is not flagged as a dev version and is not already listed in a menu
		unless self.category.blank? || !self.published? || !MenuItem.find_by_guide_id(self.id).nil?
			menu_item = MenuItem.create({:guide_id => self.id, :category => self.category, :display_order => MenuItem.get_next_display_order(self.category)})
			menu_item.save
		end
		# if a page is already listed and has been taken out of the category, listed as unpublished, a team page, or is in dev in its first revision will remove row from table
		if (self.category.blank? || !self.published?) && !MenuItem.find_by_guide_id(self.id).nil?
			menu_item = MenuItem.find_by_guide_id(self.id)
			menu_item.destroy
			
			@menu_items = MenuItem.find_all_by_category(self.category, :order => "display_order ASC")
			i = 1
			@menu_items.each do |mi|
				mi.display_order = i
				mi.save
				i += 1
			end
		end
	end

end
