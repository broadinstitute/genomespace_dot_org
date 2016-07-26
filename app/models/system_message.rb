class SystemMessage < ActiveRecord::Base

	attr_accessible :url, :content, :lock_version, :created_at, :updated_at, :priority, :expiration_date

	before_validation :create_url
	before_save :clear_exp_date
	
	validates_presence_of :content
	
	validates_uniqueness_of :url
	
	self.per_page = 3
	
	def display_date
		return self.updated_at.strftime("%m.%d.%y %I:%M%p")
	end
	
	def exp_display_date
		return self.expiration_date.nil? ? "N/A" : self.expiration_date.strftime("%A, %B %d, %Y at %I:%M%p")
	end
	
	def priority_format
		self.priority == "urgent" ? @color = "red" : @color = "green"
		return "<span style=\"color: #{@color}\">#{self.priority.capitalize}</span>"
	end
	
	def self.all_valid_messages
		return SystemMessage.where("expiration_date IS NULL or expiration_date > ?", Time.now).order("updated_at DESC")
	end
	
	def self.all_urgent_messages
		return SystemMessage.where("expiration_date IS NULL and priority = ? or expiration_date > ? and priority = ?", "urgent", Time.now, "urgent").order("updated_at DESC")
	end
	
	def self.refresh_latest_message
		@system_message = SystemMessage.all_valid_messages.first
		now = Time.now
		content = Hpricot(@system_message.content).to_plain_text
		# gets index of the phrase "operating normally", should be less than 30 in a normal status message, returns nil if not present
		message_check = content =~ /operating normally/
		# checks if above index is present and less than 30 and message is older than 23 hours old, if true just updates timestamp and url to refresh message
		if (!message_check.nil? && message_check < 30) && (@system_message.updated_at < (now - 23.hours))
			@system_message.url = nil
			@system_message.save
		# message is older than 23 hours but has different content from the standard message so emails group to update message
		elsif @system_message.updated_at < (now - 23.hours)
			GenomespaceMailer.refresh_system_message(@system_message).deliver
		end
	end
	
	def self.admin_description
		return "System Messages are short html messages that correspond to the current status of the GenomeSpace servers.  These messages are available both on the GenomeSpace homepage and inside the GSUI.  System messages have a \"priority\" setting that lets users know when a message is urgent (like when servers are going offline) or general (like when everything is operating normally).  System messages can also have an expiration date associated with them to let the website/GSUI know when to stop displaying a particular message."
	end
	
	private
	
	def create_url
		if self.url.blank? || self.url.nil?
			self.url = Time.now.strftime("%Y/%m/%d/%H-%M")
		end	
	end

	def clear_exp_date
		if self.expiration_date.blank?
			self.expiration_date = nil
		end
	end

end
