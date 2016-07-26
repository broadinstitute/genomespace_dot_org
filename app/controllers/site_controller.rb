class SiteController < ApplicationController

	before_filter :authenticate_user!, :only => ["team", "deliverables", "deliverables_report"]
	after_filter :cors_set_access_control_headers

  def index

		#@page, @alert = Page.get_home_page.check_version(params, user_signed_in?)
		#unless @alert.nil? then flash.now[:alert] = @alert.html_safe end # will have message from Page.check_version if user was not logged in

		#if @page.dev?
		#	@page = @page.get_last_live
		#end

		@highlights = Highlight.where(:dev => false).order("created_at DESC").limit(2)
		@posts = Post.where(:published => true).order("created_at DESC").limit(2)
		# @slideshow_items = SlideshowItem.order("display_order ASC").limit(6)
		# @selected_item = @slideshow_items.first
		@system_message = SystemMessage.all_valid_messages.first
		@control_offset = 6

		#@yt_feed = JSON.parse(RestClient.get "http://gdata.youtube.com/feeds/api/users/broadcancerdev/uploads/-/GenomeSpace?v=2&max-results=8&alt=json")
		#@available_videos = @yt_feed["feed"]["entry"]

  	respond_to do |format|
  		format.html { render :layout => "site_index" }
  	end
  end

  def replace_selected_item
  	params[:id].nil? ? @selected_item = SlideshowItem.first : @selected_item = SlideshowItem.find(params[:id])

  	respond_to do |format|
  		format.js
  	end
  end

  def get_other_slideshow_items
  	offset = params[:offset].to_i
  	@control_offset = offset + 6
  	@slideshow_items = SlideshowItem.order("display_order ASC").limit(6).offset(offset)

  	respond_to do |format|
  		format.js
  	end
  end

  def view
	  @page = Page.find_by_url(params[:url])

  	# clause to catch a user requesting a page by a url that isn't live anymore
  	unless @page.nil?
  		@page, @alert = @page.check_version(params, user_signed_in?)
  		# gotcha for navigating to the home page by its discrete url
  		if @page.home_page? then redirect_to :action => "index" and return end
  		unless @alert.nil? then flash.now[:alert] = @alert.html_safe end
  	else
  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "The url you requested: \"#{request.fullpath}\" does not currently exist.  Please check again before continuing.") and return
  	end

  	# check if the page is currently published or is a team page
  	if (!@page.published? || @page.team_page?) && !user_signed_in?
  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
  	elsif !@page.published? && user_signed_in?
  		flash.now[:alert] = "This page is currently not published."
  	end

  	if @page.dev? && @page.version > 1 && !user_signed_in?
  		@page = @page.get_last_live
  	elsif @page.dev? && @page.version == 1 && !user_signed_in?
  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
  	end

  	respond_to do |format|
  		format.html
  		format.json {render json: @page}
  	end
  end

  def team

  	@team_pages = Page.find_all_by_team_page(true, :order => "title ASC")

  	respond_to do |format|
  		format.html
  	end

  end
  # return a list of all deliverables
  def deliverables

  	# construct a hash of all deliverables keyed by quarter
  	@deliverables = Hash.new
  	(1..16).each do |i|
  		quarter = "Q#{i}"
  		@deliverables[quarter] = Deliverable.find_all_by_quarter(quarter, :order => "identifier ASC")
  	end

  	# construct a hash of all artifacts keyed by deliverable.id
  	@artifacts = Hash.new
  	@deliverables.each do |quarter,deliverable|
  		deliverable.each do |d|
	  		@artifacts[d.id] = Artifact.find_by_deliverable_id(d.id)
	  	end
  	end

  	respond_to do |format|
  		format.html
  	end

  end

  def deliverables_report

  	@quarter = params[:quarter]

  	# find all non-technical deliverables for the given quarter
  	@deliverables = Deliverable.find_all_by_quarter_and_tech(@quarter, false, :order => "identifier ASC")
  	@deliverable_ids = []
  	@artifacts = Hash.new
  	@deliverables.each do |d|
  		@artifacts[d.id] = Artifact.find_by_deliverable_id(d.id)
  		@deliverable_ids << d.id # for use in parsing approvals later
  	end

  	respond_to do |format|
  		format.html
  	end

  end

  def process_deliverables_report

  	@report = params[:report]
  	# grab array of deliverable ids to process
  	tmp = params[:report][:deliverable_ids][1..-2].split(',')
  	@ids = []
  	tmp.each {|t| @ids << t.strip.to_i }
  	# array to hold each deliverable for confirmation email sent to genomespace team
  	@deliverables = []
  	# process each approval
  	@ids.each do |i|
  		@deliverable = Deliverable.find(i)
  		@deliverable.completed = @report["deliverable_#{i}_completed"].to_i
  		@deliverable.approval_comments = @report["deliverable_#{i}_approval_comments"]
  		@deliverable.approved_by = @report["deliverable_#{i}_approved_by"]
  		@deliverable.save
  		@deliverables << @deliverable
  	end
  	@host = request.host_with_port
  	GenomespaceMailer.deliverables_report_email(@deliverables, @host).deliver
  	redirect_to request.referrer, notice: "Your approvals have been recorded."

  end

  def register
  	@username = params[:username]
  	@email = params[:email]

  	respond_to do |format|
  		format.html
  	end

  end

  # register for a genomespace account (note this is for genomespace as a service, not the genomespace website).
  def process_registration

  	@account = params[:account]
  	@host = request.env['HTTP_HOST']

  	# confirm passwords match
  	unless @account["password"] == @account["password_confirm"]
  		redirect_to(register_account_path(:username => @account["username"],:email => @account["email"]), :alert => "<h3 class='invite_alert'>Passwords do not match.  Please re-enter before continuing.</h3>".html_safe) and return
  	end

  	# make post to identity server and handle response (either 200 or 409)

  	RestClient.post("https://identity.genomespace.org/identityServer/usermanagement/register/initial", {'username' => @account["username"], 'email' => @account["email"], 'roles' => "public", 'password' => @account["password"]}.to_json, :content_type => :json) {|response, request, result, &block|

			case response.code
			when 200
		  	# server does not return any response

		  when 409
		  	# 409 is returned when the username already exists
		  	logger.error "Error: #{response.code}, #{response}"
		  	redirect_to(register_account_path(:username => @account["username"],:email => @account["email"]), :alert => "<h3 class='invite_alert'>An error has occured while processing your request: #{response}<br/>If you believe this has happened in error, you may <a href=\"https://gsui.genomespace.org/jsui/gsui.html\">log in</a> now or request a <a href=\"https://identity.genomespace.org:8444/identityServer/forgotPassword.html?openId.return_to='https://gsui.genomespace.org/jsui/openIdClient?is_cancel=true'\">new password</a>.</h3>".html_safe) and return
		  else
		  	# generic catch-all
		  	logger.error "Error: #{response.code}, #{response}"
		  	redirect_to(register_account_path, :alert => "An HTTP #{response.code} exception has been raised: <br />Response: #{response}".html_safe) and return
		  end
		}

  	respond_to do |format|
  		format.html
  	end
  end

  def request_invite

  	respond_to do |format|
  		format.html
  	end

  end

  def process_invite
  	if params[:invite][:email].blank? || (params[:invite][:email] =~ Devise.email_regexp).nil?
  		redirect_to request_invite_path, :alert => "You must enter a valid email address." and return
  	end
  	@invite = Invite.create(params[:invite])

  	redirect_to request_received_path
  end

  # display a list of all available docs, latest versions only
  def support

  	@docs = Doc.get_latest_components
  	@guides = Guide.all(:order => "title ASC")

  	respond_to do |format|
  		format.html
  		format.json {render json: [@docs, @guides]}
  	end

  end

  def genomespace_google_groups

  	unless params[:email].nil? || params[:email].blank?
	  	@lists = []
	  	params.each {|k,v| v == "1" ? @lists << k : nil}
	  	GenomespaceMailer.subscribe_email_list(params[:email], @lists).deliver
	  else
	  	redirect_to support_path, alert: "You must enter an email address to subscribe to a list." and return
		end

		respond_to do |format|
			format.html
		end
  end

  # displays current doc along with a dropdown to easily load other docs
  def view_docs

  	# if user has selected a component from the dropdown, then overwrite the url to the selected component to load correct doc
  	if params[:select]
  		params[:url] = params[:select][:component]
  	end

  	@doc = Doc.find_by_url(params[:url])
  	if @doc.nil?
  		@doc = Doc.get_latest_version(params[:url])
  	end
  	@doc, @alert = @doc.check_version(params, user_signed_in?)
  	unless @alert.nil? then flash.now[:alert] = @alert.html_safe end
  	if @doc.dev? && !user_signed_in?
  		@doc = @doc.get_last_live
  	elsif @doc.dev? && @doc.version == 1 && !user_signed_in?
  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
  	end
  	@previous_versions = Doc.find_all_by_component(@doc.component, :order => "dev_stage DESC, maj_version DESC, min_version DESC")

  	respond_to do |format|
  		format.html
  		format.json {render json: @doc}
  	end

  end

  def view_guide

  	@guide = Guide.find_by_url(params[:url])
  	@guide.title == "Recipes" && !params[:display_url].nil? ? @recipe_view = true : @recipe_view = false
  	unless @recipe_view == true
  		if user_signed_in?
  			@guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")
  		else
		  	@guide_sections = GuideSection.find_all_by_guide_id_and_published(@guide.id, true, :order => "display_order ASC")
			end
	  	if params[:display_url].nil?
	  		params[:display_url] = @guide_sections.first.display_url
	  	end
	  	# copy array for use in table of contents (toc)
	  	@toc = Array.new(@guide_sections)
	  	# create array of links for recipes menu in gsui
	  	@guide_sections_links = []
	  	@guide_sections.each do |gs|
	  		@guide_sections_links << {title: gs.title, display_url: gs.display_url}
	  	end
	  	# inserting nil objects on the beginning and end of array for use in navigation links (disables if prev/next are nil objects)
	  	@guide_sections.insert(0, nil)
	  	@guide_sections.push(nil)
	  	# loads requested section by pulling display order param out of url.  Array is ordered by same param.
	  	@requested_section, @alert = GuideSection.find_by_guide_id_and_display_url(@guide.id, params[:display_url]).check_version(params, user_signed_in?)
	  	if @requested_section.dev? && @requested_section.version > 1 && !user_signed_in?
	  		@requested_section = @requested_section.get_last_live
	  	elsif (@requested_section.dev? && @requested_section.version == 1 && !user_signed_in?) || (!@requested_section.published? && !user_signed_in?)
	  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
	  	end
	  else
	  	@recipe, @alert = GuideSection.find_by_guide_id_and_display_url(@guide.id, params[:display_url]).check_version(params, user_signed_in?)
	  	if @recipe.dev? && @recipe.version > 1 && !user_signed_in?
	  		@recipe = @recipe.get_last_live
	  	elsif (@recipe.dev? && @recipe.version == 1 && !user_signed_in?) || (!@recipe.published? && !user_signed_in?)
	  		redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
	  	end
	  	@content = Hpricot(@recipe.content)
	  	@toc = @content.search("//div[@class='recipe_toc']")
	  	@toc.each {|toc| puts toc.inner_html}
	  end
	  unless @alert.nil? then flash.now[:alert] = @alert.html_safe end
  	respond_to do |format|
  		format.html
  		format.json { render json: {:guide => @guide, :guide_sections => @guide_sections_links} }
  	end

  end

  def print_guide

  	@guide = Guide.find_by_url(params[:url])
  	if user_signed_in?
			@guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")
		else
	  	@guide_sections = GuideSection.find_all_by_guide_id_and_published(@guide.id, true, :order => "display_order ASC")
  	end
  	respond_to do |format|
  		format.html { render :layout => "print" }
  	end
  end

  def recipe_instructions

		@guide = Guide.find_by_url(params[:url])
		@recipe = GuideSection.find_by_guide_id_and_display_url(@guide.id, params[:display_url])
		@content = Hpricot(@recipe.content)
		@steps = @content.search("//div[@class='recipe_step']")

		respond_to do |format|
			format.html { render :layout => "print" }
		end
  end

  def rescue_from_nil_page
  	redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "The url you requested: \"#{request.fullpath}\" does not currently exist.  Please check again before continuing.") and return
  end

  def search

  	if params[:search]
	  	@results = ThinkingSphinx.search params[:search], :classes => [Page, Doc, GuideSection, Tool, Highlight, Post], :page => params[:page], :per_page => 10
	  	@results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
  	end
	  respond_to do |format|
	  	format.html
	  end
	end

	def google_search
		redirect_to "http://www.google.com#q=#{params[:search]}+site:www.genomespace.org"
	end

	def tools
		if params[:lookup_name].nil?
			user_signed_in? ? @tools = Tool.order("name ASC") : @tools = Tool.find_all_by_published(true, order: "name ASC")
			@help_links = Hash.new
			@tools.each {|tool| @help_links[tool.id] = HelpLink.find_all_by_tool_id(tool.id)}
		else
			@tool = Tool.find_by_lookup_name(params[:lookup_name])
			if @tool.nil?
				redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "The tool you requested does not exist.  Please check the name again before continuing.") and return
			elsif !@tool.published? && !user_signed_in?
				redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
			end
			@help_links = HelpLink.find_all_by_tool_id(@tool.id)
			@guide = Guide.find_by_title("Recipes")
			@recipes = GuideSection.find_all_by_guide_id(@guide.id, :conditions => ["title LIKE ?", "%" + @tool.name + "%"])
		end

		respond_to do |format|
			format.html
		end
	end

	def view_highlights
		if params[:url]
			@highlight = Highlight.find_by_url(params[:url])
			if @highlight.dev? && !user_signed_in?
				redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
			end
		elsif params[:url].nil? && user_signed_in?
			@highlights = Highlight.paginate(:page => params[:page]).order("created_at DESC")
		else
			@highlights = Highlight.where(:dev => false).paginate(:page => params[:page]).order("created_at DESC")
		end

		respond_to do |format|
			format.html
		end
	end

	def view_blog
		if params[:url]
			@post = Post.find_by_url(params[:url])
			if !@post.published? && !user_signed_in?
				redirect_to(request.referrer.nil? ? site_path : request.referrer, :alert => "You must be <a href='/users/sign_in'>logged in</a> to view: \"#{request.fullpath}.\"".html_safe) and return
			end
			@comments = Comment.find_all_by_post_id(@post.id, :order => "created_at DESC")
		elsif params[:url].nil? && user_signed_in?
			@posts = Post.paginate(:page => params[:page]).order("created_at DESC")
		else
			@posts = Post.where(:published => true).paginate(:page => params[:page]).order("created_at DESC")
		end

		respond_to do |format|
			format.html
		end
	end

	def latest_news
		latest_post = Post.order("created_at DESC").first
		latest_highlight = Highlight.order("created_at DESC").first
		Rails.env == "production" ? root = "http://www.genomespace.org" : root = root_url.chomp("/")

		@post = {id: latest_post.id, url: root + view_context.post_url(latest_post), title: latest_post.title, created_at: latest_post.created_at, updated_at: latest_post.updated_at}
		@highlight = {id: latest_highlight.id, url: root + view_context.highlight_url(latest_highlight), title: latest_highlight.title, created_at: latest_highlight.created_at, updated_at: latest_highlight.updated_at}
		@latest = {post: @post, highlight: @highlight}

		respond_to do |format|
			format.json { render json: @latest }
		end
	end

	def create_comment
		@post = Post.find(params[:id])
		@url = @post.url
		if simple_captcha_valid?
			params[:comment][:author].blank? ? params[:comment][:author] = "Anonymous" : nil
			@comment = Comment.new(params[:comment])
		else
			redirect_to view_blog_path(url: @url), alert: "Your captcha validation did not match.  Please try again." and return
		end
		respond_to do |format|
		  if @comment.save
		    format.html { redirect_to view_blog_path(url: @url), notice: 'Your comment has successfully been posted.' }
		  else
		    format.html { redirect_to view_blog_path(url: @url), alert: 'Your comment could not be saved.  Please be sure to enter your name and comments before submitting.' }
		  end
		end
	end

	def report_abuse
		@comment = Comment.find(params[:id])
		@post = Post.find(@comment.post_id)

		unless @comment.nil?
			GenomespaceMailer.report_abuse(@comment, @post, request.host_with_port).deliver
			redirect_to request.referrer, notice: "Thank you for your report.  We will review the comment in question and take any appropriate action as necessary."
		else
			redirect_to request.referrer, alert: "We were unable to complete your request.  Please try again."
		end
	end

	def view_system_message
		if request.fullpath.split(".")[0] == "/system-status/latest"
			@system_message = SystemMessage.all_valid_messages.first
		else
			@system_message = SystemMessage.find_by_url(params[:url])
		end

		respond_to do |format|
			format.html
      format.json { render json: @system_message }
		end
	end

	def view_system_messages
		if request.format == "text/html"
			@system_messages = SystemMessage.all_valid_messages.paginate(:page => params[:page])
		else
			@system_messages = SystemMessage.all_valid_messages
		end

		respond_to do |format|
			format.html
			format.json {render json: @system_messages}
			format.atom {render :layout => false}
		end
	end

	def view_urgent_system_messages

		@system_messages = SystemMessage.all_urgent_messages

		respond_to do |format|
			format.html
			format.json {render json: @system_messages}
		end
	end

	def server_properties

		@server_property = ServerProperty.first

		respond_to do |format|
			format.html {render :text => @server_property.content, :content_type => :text}
			format.text
			format.json {render json: @server_property}
		end
	end

	private

	def cors_set_access_control_headers
		if request.fullpath.split('.')[1] == 'json'
			headers['Access-Control-Allow-Origin'] = '*'
		end
	end
end
