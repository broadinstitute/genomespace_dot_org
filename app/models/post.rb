class Post < ActiveRecord::Base

	attr_accessible :title, :content, :published, :url, :author, :created_at, :updated_at, :delta, :lock_version

	has_many :comments

	before_validation :create_url
	
	validates_presence_of :title, :content, :author
	
	validates_uniqueness_of :url
	
	self.per_page = 10

	def display_date
        return self.updated_at.strftime("%A, %B %d, %Y at %I:%M%p")
    end

	def updated_date_time
		return self.updated_at.strftime("%A, %B %d, %Y at %I:%M%p")
	end

	def created_date_time
        return self.created_at.strftime("%A, %B %d, %Y at %I:%M%p")
    end

    def updated_date_only
		return self.updated_at.strftime("%A, %B %d, %Y")
	end

	def created_date_only
        return self.created_at.strftime("%A, %B %d, %Y")
    end

	def self.admin_description
		return "Posts are blog post entries that are html objects with a timestamped URL.  While similar to highlights, blog posts are intended to be more informal and to announce feature enhancements, bug fixes and similar topics."
	end
	
	def get_comments_count(post_id)
		return Comment.count(:conditions => "post_id = #{post_id}")
	end
	
	def plain_content
		Hpricot(self.content).to_plain_text
	end
	
	private
	
	def create_url
		if self.url.blank? || self.url.nil?
			title_string = self.title.downcase.gsub(/[^a-zA-Z0-9]+/, "-").chomp("-")
			date_string = Date.today.to_s(:db).split[0].gsub(/-/, "/")
			self.url = date_string + "/" + title_string
		end	
	end
end
