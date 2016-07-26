class PagesController < ApplicationController
 
 	layout "admin"
 
 	before_filter do 
 		authenticate_user!
 		authenticate_cms_admin
 	end
 
  # GET /pages
  # GET /pages.json
  def index
  	if params[:view] == "last"
  		@pages = Page.find_all_by_created_by(current_user.email)
  		unless @pages.blank?
  			@pages = [@pages.sort{|x,y| x.updated_at <=> y.updated_at}.last]
  		end
  	elsif params[:view] == "unpublished"
  		@pages = Page.find_all_by_published(false)
  	elsif params[:view] == "dev"
  		@pages = Page.find_all_by_dev(true)
  	else
	    params[:search] ? @pages = Page.search(params[:search]) : @pages = Page.all
		end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: "\"#{@page.title}\" was successfully created." }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page, notice: "\"#{@page.title}\" was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    unless MenuItem.find_by_page_id(@page.id).nil?
    	@menu_item = MenuItem.find_by_page_id(@page.id)
    	@menu_item.destroy
    end
    @page.destroy
    

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :ok }
    end
  end
  
  def show_revisions
  	@page = Page.find(params[:id])
  	@revisions = @page.versions
  	
  	respond_to do |format|
  	  format.html
  	  format.json { render json: @page }
  	end
  end
  
  def revert_revision
  
  	@page = Page.find(params[:id])
  	@lock_version = @page.lock_version
  	@page.revert_to(params[:version].to_i)
  	@page.lock_version = @lock_version
  	@page.updated_by = current_user.email
  	@page.save
  	
  	redirect_to show_revisions_path, :notice => "Successfully reverted to revision ##{params[:version]}."
  
  end
  
  def diff_content
  
  	@page = Page.find(params[:id])
  	@revision = Page.find(params[:id])
  	@revision.revert_to(params[:revision].to_i)
  	
  	@page.title = Differ.diff_by_word(@page.title, @revision.title).format_as(:html)
  	@page.content = Differ.diff_by_line(@page.content, @revision.content).format_as(:html)
  	
  	respond_to do |format|
  		format.html { render :layout => "site" }
  	end
  
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@page.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
