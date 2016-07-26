class Doc < ActiveRecord::Base

	attr_accessible :component, :maj_version, :min_version, :dev_stage, :url, :contents, :created_at, :updated_at,
									:created_by, :updated_by, :delta, :deprecated, :dev, :lock_version

	versioned :if => Proc.new {|doc| doc.component_changed? || doc.dev_stage_changed? || doc.maj_version_changed? || doc.min_version_changed? || doc.contents_changed? }
	
	validates_presence_of :component, :maj_version, :min_version, :contents
	
	validates_uniqueness_of :url
	
	before_validation  :create_url
	
	before_save :fix_ckeditor_attachment_paths
	
	def self.admin_description
		return "Docs are html objects that are technical documentation for various GenomeSpace APIs or features (called a component in the database).  Each component can have multiple versions and development stages that exist independently of each other (i.e. beta 1.0, beta 2.0, prod 1.1, etc.).  Users can see each version of a given component on the live site by using a dropdown at the top of the page."
	end
		
	# checks to see if there is a revisions specified in the url and reloads if necessary.  Returns an alert as well if user is not signed in.
	def check_version(params, user_signed_in)
		
		if params[:rev] && user_signed_in == true
			self.revert_to(params[:rev].to_i)
			@alert = ""
		elsif params[:rev] && user_signed_in == false
			@alert = "You need to be logged in to view previous revisions of this doc.  Please <a href=\"/users/sign_in\">log in</a> first."
		end
	
		return self, @alert
	end
	
	# creates a new url from the existing and increments indicated version number.  if url has been too customized, appends numbers on the end.
	def new_version_url(version)
		url_parts = self.url.split("-")
		unless url_parts.size < 3
			case version
			when "major"
				url_parts[url_parts.size - 2] = self.maj_version += 1
			when "minor" 
				url_parts[url_parts.size - 1] = self.min_version += 1
			end
		else
			case version
			when "major"
				url_parts.push(self.maj_version += 1, self.min_version)
			when "minor" 
				url_parts.push(self.maj_version, self.min_version += 1)
			end
		end
		return url_parts.join("-")
	end
	
	# returns an array of docs that consists of the latest versions of each available component
	def self.get_latest_components
	
		@docs = []
	
		@components = Doc.all.collect(&:component).uniq
		@components.each do |component|
			doc = Doc.find_all_by_component(component).sort{|x,y| x.get_version <=> y.get_version}.last
			unless doc.deprecated? 
				@docs << doc
			end
		end
		
		return @docs.sort {|x,y| x.component <=> y.component}
		
	end
	
	# return complete version number in standard decimal format, e.g. "beta 3.1" or "2.0"
	def get_version
		self.dev_stage.blank? ? dev_stage_string = "" : dev_stage_string = self.dev_stage + " "
		return dev_stage_string + self.maj_version.to_s + "." + self.min_version.to_s
	end
	
	def get_last_live
	
		@requested_doc = Doc.find(self.id)	
		while @requested_doc.dev == true
			# gotcha for when all revisions of a doc are dev, so return the previous version (beta 1.1 vs. beta 1.2)
			if @requested_doc.dev == true && @requested_doc.version == 1
				@all_versions = Doc.find_all_by_component(@requested_doc.component).sort{|x,y| x.get_version <=> y.get_version}.reverse
				@all_versions.delete_if {|d| d.get_version >= @requested_doc.get_version}
				@requested_doc = @all_versions.first
			else
				@requested_doc.revert_to(@requested_doc.version - 1)
			end
		end
		return @requested_doc	
	end
	
	def self.get_latest_version(url)
	
		return Doc.find_by_sql("SELECT * from docs where url LIKE '#{url}%'").sort{|x,y| x.get_version <=> y.get_version}.last
	
	end
	
	def plain_content
		Hpricot(self.contents).to_plain_text
	end
	
	private
	
	# create a url for a doc using the component, version and dev stage, e.g. "atm-beta-3-1"
	def create_url
		if self.url.blank?
			self.dev_stage.blank? ? dev_stage_string = "" : dev_stage_string = "-" + self.dev_stage + "-"
			component_string = self.component.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
			version_string = self.maj_version.to_s + "-" + self.min_version.to_s
			self.url = component_string + dev_stage_string + version_string
		end
	end 
	
	# to fix bug with hrefs not being saved correctly
	def fix_ckeditor_attachment_paths
	  if self.contents.include?("_cke_saved_href")
	  	self.contents.gsub!(/href=\"javascript:void\(0\)\/\*\d+\*\/\"/, '')
	  	self.contents.gsub!(/_cke_saved_href/, 'href')
	  end
	end
end
