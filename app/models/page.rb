class Page < ActiveRecord::Base

	attr_accessible :title, :url, :content, :home_page, :published, :created_at, :updated_at, :created_by, :updated_by, :desc, :category, :delta, :team_page, :dev, :lock_version, :landing_page, :showTitle
									
	versioned :if => Proc.new {|page| page.title_changed? || page.url_changed? || page.category_changed? || page.desc_changed? || page.content_changed? }
	
	has_one :menu_item
	
	validates_presence_of :title, :content
	validates_uniqueness_of :url
	
	before_validation  :create_url
	
	before_save do
		check_existing_home_page
		check_landing_page
		fix_ckeditor_attachment_paths
	end
	
	after_save :add_to_menu
	
	def self.get_home_page
		return Page.find_by_home_page(true)
	end
	
	# checks to see if there is a revisions specified in the url and reloads if necessary.  Returns an alert as well if user is not signed in.
	def check_version(params, user_signed_in)
		if params[:rev] && user_signed_in == true
			self.revert_to(params[:rev].to_i)
			@alert = ""
		elsif params[:rev] && user_signed_in == false
			@alert = "You need to be logged in to view previous revisions of this page.  Please <a href=\"/users/sign_in\">log in</a> first."
		end
		return self, @alert
	end
	
	def get_last_live
	
		page = Page.find(self.id)	
		while page.dev == true && page.version > 1
			page.revert_to(page.version - 1)
		end
		return page
	
	end
	
	def select_title
		return self.title + (self.home_page? ? " (home page)" : "")
	end
	
	def self.admin_description
		return "Pages are essentially html objects with extra metadata, and comprise the bulk of content on the GenomeSpace website.  Pages also have revisions which act as version control for each page, and can be reverted, diffed and (un)published as necessary."
	end
	
	def plain_content
		Hpricot(self.content).to_plain_text
	end
	
	private
	
	# creates url for page by using the page title and replacing spaces with dashes.  Also removes reserved non-alphanumeric characters that would break the url.
	def create_url
		if self.url.blank?
			self.url = self.title.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
		end	
	end
	
	# looks to see if newly saved page is being declared as the home page.  This method finds the old home page and resets the boolean to false.
	def check_existing_home_page
		if self.home_page?
			@old_home = Page.get_home_page
			unless @old_home.nil? || @old_home == self
				@old_home.home_page = false
				@old_home.save
			end
		end
		
	end
	
	# looks to see if newly saved page is being declared as the landing page for its category.  This method finds the old home page and resets the boolean to false.
	def check_landing_page
		if self.landing_page? && !self.category.blank?
			@old_landing_page = Page.find_by_category_and_landing_page(self.category, true)
			unless @old_landing_page.nil? || @old_landing_page == self
				@old_home.landing_page = false
				@old_home.save
			end
		elsif self.landing_page? && self.category.blank?
			self.landing_page = false
		end
		
	end
	
	# adds the page to the corresponding menu by creating an entry in the menu_items table
	def add_to_menu
		# only creates menu item if the page has a category, is published, is not flagged as a dev version and is not already listed in a menu
		unless self.category.blank? || !self.published? || self.team_page? || self.dev? || !MenuItem.find_by_page_id(self.id).nil? || self.landing_page?
			menu_item = MenuItem.create({:page_id => self.id, :category => self.category, :display_order => MenuItem.get_next_display_order(self.category)})
			menu_item.save
		end
		# if a page is already listed and has been taken out of the category, listed as unpublished, a team page, or is in dev in its first revision will remove row from table
		if (self.category.blank? || !self.published? || self.team_page? || (self.dev? && self.version == 1) || self.landing_page?) && !MenuItem.find_by_page_id(self.id).nil?
			menu_item = MenuItem.find_by_page_id(self.id)
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
	
	# to fix bug with hrefs not being saved correctly
	def fix_ckeditor_attachment_paths
	  if self.content.include?("_cke_saved_href")
	  	self.content.gsub!(/href=\"javascript:void\(0\)\/\*\d+\*\/\"/, '')
	  	self.content.gsub!(/_cke_saved_href/, 'href')
	  end
	end
end
