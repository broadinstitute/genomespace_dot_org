class Comment < ActiveRecord::Base

	attr_accessible :post_id, :author, :content, :created_at, :updated_at

	belongs_to :post
	validates_presence_of	:content
	
end
