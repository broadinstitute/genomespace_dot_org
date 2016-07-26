class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # include SimpleCaptcha::ControllerHelpers
  
  before_filter :authenticate_user!, :only => :admin 
  before_filter :log_incoming_ip
   
	def authenticate_cms_admin
		unless current_user.cms_admin?
			redirect_to(site_path, notice: "You do not have permission to edit content for this site.") and return
		end
	end  
  
  def authenticate_super_admin
  	unless current_user.super_admin?
  		redirect_to(request.referrer, notice: "You do not have permission to create user accounts for this site.") and return
  	end
  end 
  
  def route_action
  	unless params[:action_path].nil?
  		path = "/" + params[:action_path]
  		redirect_to path
  	else
  		flash[:alert] = "No action specified"
  	end
  end 
  
  def admin
  
  	respond_to do |format|
  		format.html
  	end
  end
  
  def log_incoming_ip
  	ip =  request.headers["X-Forwarded-For"].nil? ? request.remote_ip : request.headers["X-Forwarded-For"].split(",")[0]
  	logger.info "IP_ADDRESS #{ip}"
  end
  
  # rescue page edit form from a locked version (2 editors editing the same page at the same time)
  rescue_from ActiveRecord::StaleObjectError do |exception|
  	respond_to do |format|
  		format.html {
  			correct_stale_object_version
  			stale_page_recovery_action
  		}
  		format.xml  { head :conflict }
  	end
  end
  
  private
  def stored_location_for(resource)
    session.delete(:return_to) || super(resource)
  end
  
  protected
  
  def stale_page_recovery_action
    flash.now[:alert] = "Another user has edited this item since you accessed the edit form.  Please copy your edits to the clipboard and exit out of the page editor to reload the content."
    render :edit, :status => :conflict
  end
end
