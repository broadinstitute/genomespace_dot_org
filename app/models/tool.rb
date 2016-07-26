class Tool < ActiveRecord::Base

	attr_accessible :name, :desc, :delta, :created_at, :updated_at, :lookup_name, :lock_version, :published, :help_links_attributes

	has_many  :help_links, :dependent => :destroy
	
	validates_presence_of  :name
	validates_uniqueness_of  :name, :lookup_name
	
	before_validation  :create_lookup_name
	
	accepts_nested_attributes_for :help_links, :allow_destroy => true, :reject_if => lambda {|h| h[:title].blank? || h[:url].blank?}
	
	def self.admin_description
		return "Tools are html objects that act as help pages for each tool that has been incorporated into GenomeSpace.  They contain high-level descriptions of the tools along with one or more \"help links\" that point to tool websites, documentation and other relevant resources."
	end
	
	def plain_content
		Hpricot(self.desc).to_plain_text
	end
	
	private
	
	def create_lookup_name
		self.lookup_name = self.name.downcase.gsub(/[^a-zA-Z0-9]+/, "_").chomp("-")
	end
end
