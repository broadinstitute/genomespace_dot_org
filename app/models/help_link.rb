class HelpLink < ActiveRecord::Base

	attr_accessible :tool_id, :title, :url, :created_at, :updated_at

	belongs_to  :tool

end
