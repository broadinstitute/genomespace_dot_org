class Highlight < ActiveRecord::Base

	attr_accessible :title, :content, :dev, :url, :created_by, :created_at, :updated_at, :delta, :lock_version

	validates_presence_of :title, :content
	validates_uniqueness_of :url
	
	before_validation  :create_url
	
	before_save  :fix_ckeditor_attachment_paths
	
	self.per_page = 10
	
	def view_date
		return self.updated_at.to_s(:long)
	end
	
	def view_author
		return self.created_by.split("@")[0]
	end
	
	def self.admin_description
		return "Highlights are html objects that nearly identical to blog posts, the only difference being that highlights are indented to act as \"news items\" that announce press items, public outreach events and other similar topics.  As such, there is no date added to their URLs like blog posts have, and there tend to be fewer of them."
	end
	
	def plain_content
		Hpricot(self.content).to_plain_text
	end
	
	private
	
	def create_url
		if self.url.blank?
			self.url = self.title.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
		end	
	end
	
	def fix_ckeditor_attachment_paths
	  if self.content.include?("_cke_saved_href")
	  	self.content.gsub!(/href=\"javascript:void\(0\)\/\*\d+\*\/\"/, '')
	  	self.content.gsub!(/_cke_saved_href/, 'href')
	  end
	end
end
