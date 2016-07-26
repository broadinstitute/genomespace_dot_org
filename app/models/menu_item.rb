class MenuItem < ActiveRecord::Base

	attr_accessible :page_id, :guide_id, :display_order, :category, :created_at, :updated_at

	belongs_to :page
	belongs_to :guide
	
	def self.get_next_display_order(category)
		last_item = MenuItem.find_all_by_category(category, :order => "display_order ASC").last
		if last_item.nil?
			return 1
		else
			return last_item.display_order += 1
		end
	end
	
	def self.admin_description
		return "Menu items correspond to pages, guides and docs that have been published (and therefore added to the navigation menus).  Each menu item can be reordered inside its corresponding menu to change the menu appearance on the live site."
	end

end
