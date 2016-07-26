class ServerProperty < ActiveRecord::Base
  attr_accessible :content
  
  def self.admin_description
  	return "GenomeSpace server url properties are used by the GenomeSpace CDK and P2 tools to get the per-environment server urls.  There can only be one server url properties record at any given time."
  end
end
