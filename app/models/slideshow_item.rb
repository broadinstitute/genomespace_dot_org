class SlideshowItem < ActiveRecord::Base

	attr_accessible :title, :description, :url, :created_at, :updated_at

	after_destroy :reorder_all_items

	has_attached_file :image,
										:url => "/slideshow_items/:id/:style_:basename.:extension",
										:path => ":rails_root/public/slideshow_items/:id/:style_:basename.:extension",
										:styles => { :thumb => '126' },
										:convert_options => {:thumb => "-gravity center -extent '126x95'"}
										
	def self.get_next_display_order
		count = SlideshowItem.count
		return count.nil? ? 1 : count + 1
	end
	
	def reorder_all_items
	
		i = 1
		SlideshowItem.order("display_order ASC").each do |si|
			si.display_order = i
			si.save
			i += 1
		end
		
	end
	
	def self.admin_description
		return "<font color='red'>Slideshow Items are deprecated and no longer in use</font>."
	end

end
