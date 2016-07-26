class Invite < ActiveRecord::Base

	attr_accessible :email, :sent_invite, :created_at, :updated_at, :emailed

	def display_date
		return self.created_at.strftime("%B %d, %Y at %I:%M%P")
	end
	
	def email_display_date
		return self.emailed.strftime("%B %d, %Y at %I:%M%P")
	end
	
	def self.admin_description
		return "<font color='red'>Invites are deprecated and no longer in use</font>."
	end
end
