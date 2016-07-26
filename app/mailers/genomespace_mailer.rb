class GenomespaceMailer < ActionMailer::Base
  default from: "do-not-reply@genomespace.org"
  
  def new_user_email(user, password, host)
    
  	@user = user
  	@password = password
		@host = Rails.env == "production" ? "www.genomespace.org" : host
		
		
  	mail(:to => @user.email, :subject => "Details for your GenomeSpace.org account") do |format|
  		format.text { render "new_user_email" }
  		format.html { render "new_user_email" }
  	end
  
  end
  
  def new_gs_account(account, host)
  	
  	@account = account
  	@host = Rails.env == "production" ? "www.genomespace.org" : host
  	
  	mail(:to => @account["email"], :subject => "Details for your new GenomeSpace User account") do |format|
  		format.text { render "new_gs_account" }
  		format.html { render "new_gs_account" }
  	end
  	
  end
  
  def deliverables_report_email(deliverables, host)
  
  	Rails.env == "development" ? @to_email = "liefeld@broadinstitute.org" : @to_email = "gs-info@broadinstitute.org"
  	@deliverables = deliverables
  	@host = host
  	@quarter = @deliverables.first.quarter
  	@approver = @deliverables.first.approved_by
  	
  	mail(:to => "gs-info@broadinstitute.org", :subject => "GenomeSpace Deliverables Report for #{@quarter}") do |format|
  		format.text { render "deliverables_report_email" }
  		format.html { render "deliverables_report_email" }
  	end
  end
  
  def send_registration_invitation(invite)
  
  	@email = invite.email
  
		mail(:to => @email, :subject => "Your GenomeSpace account is ready") do |format|
			format.text { render "reg_invite" }  
			format.html { render "reg_invite" }  
		end
  end
  
  def refresh_system_message(system_message)
  
  	Rails.env == "development" ? @to_email = "bistline@broadinstitute.org" : @to_email = "gs-dev@broadinstitute.org"
  	@system_message = system_message
  	
  	mail(:to => @to_email, :subject => "GenomeSpace system status message needs updating") do |format|
  		format.html { render "refresh_system_message" }
  	end
  end
  
  def subscribe_email_list(email, lists)
  
  	@email = email
  	@lists = lists.collect {|list| list + "+subscribe@broadinstitute.org"}
  	
  	mail(:to => @lists, :from => @email)
  
  end
  
  def report_abuse(comment, post, host)
  	
  	@comment = comment
  	@post = post
  	@host = Rails.env == "production" ? "www.genomespace.org" : host
  	Rails.env == "development" ? @to_email = "bistline@broadinstitute.org" : @to_email = "gs-dev@broadinstitute.org"
  
  	mail(:to => @to_email, :subject => "Inappropriate comment reported on: #{@post.title}") do |format|
  		format.html { render "report_abuse" }
  	end
  end
end
