class DocsController < ApplicationController
  
  layout "admin"
  
  before_filter do 
  	authenticate_user!
  	authenticate_cms_admin
  end
  
  # GET /docs
  # GET /docs.json
  def index
    if params[:view] == "last"
    	@docs = Doc.find_all_by_created_by(current_user.email)
    	unless @docs.blank?
    		@docs = [@docs.sort{|x,y| x.updated_at <=> y.updated_at}.last]
    	end
    elsif params[:view] == "deprecated"
    	@docs = Doc.find_all_by_deprecated(true)
    else
    	params[:search] ? @docs = Doc.search(params[:search]) : @docs = Doc.all
    end
    @latest_docs = Doc.get_latest_components

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @docs }
    end
  end

  # GET /docs/1
  # GET /docs/1.json
  def show
    @doc = Doc.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @doc }
    end
  end

  # GET /docs/new
  # GET /docs/new.json
  def new
  	if params[:id]
  		@old_doc = Doc.find(params[:id])
  		@doc = Doc.new({:component => @old_doc.component, :maj_version => (params[:version] == "major" ? @old_doc.maj_version + 1 : @old_doc.maj_version ), :min_version => (params[:version] == "minor" ? @old_doc.min_version + 1 : @old_doc.min_version), :dev_stage => @old_doc.dev_stage, :url => @old_doc.new_version_url(params[:version]), :contents => @old_doc.contents})
  	else
	    @doc = Doc.new
		end
		
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @doc }
    end
  end

  # GET /docs/1/edit
  def edit
    @doc = Doc.find(params[:id])
  end

  # POST /docs
  # POST /docs.json
  def create
    @doc = Doc.new(params[:doc])

    respond_to do |format|
      if @doc.save
        format.html { redirect_to @doc, notice: "\"#{@doc.component}\" was successfully created." }
        format.json { render json: @doc, status: :created, location: @doc }
      else
        format.html { render action: "new" }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /docs/1
  # PUT /docs/1.json
  def update
    @doc = Doc.find(params[:id])
    # do a check to make sure the editor hasn't incremented the version without making a new doc first - if true then create new doc instead
    @version = params[:doc][:dev_stage] + " " + params[:doc][:maj_version] + "." + params[:doc][:min_version]
		unless @doc.get_version == @version
			@new_doc = Doc.new(params[:doc])
			# increment the url as necessary
			if @new_doc.maj_version > @doc.maj_version
				url_parts = @new_doc.url.split("-")
				url_parts[url_parts.size - 2] = @new_doc.maj_version
				url_parts[url_parts.size - 1] = @new_doc.min_version
				@new_doc.url = url_parts.join("-")
			elsif @new_doc.maj_version == @doc.maj_version && @new_doc.min_version > @doc.min_version
				url_parts = @new_doc.url.split("-")
				url_parts[url_parts.size - 1] = @new_doc.min_version
				@new_doc.url = url_parts.join("-")
			else
				# default case where possibly the editor has graduated the dev stage to something different, will completely rebuild url using create_url at save
				@new_doc.url = ""
			end
			@new_doc.save
			redirect_to @new_doc, alert: "You have incremented the version for this doc, so a new doc was created with the version \"#{@version}\" instead." and return
		end
		
    respond_to do |format|
      if @doc.update_attributes(params[:doc])
        format.html { redirect_to @doc, notice: "\"#{@doc.component}\" was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docs/1
  # DELETE /docs/1.json
  def destroy
    @doc = Doc.find(params[:id])
    @doc.destroy

    respond_to do |format|
      format.html { redirect_to docs_url }
      format.json { head :ok }
    end
  end
  
  def show_revisions
  	@doc = Doc.find(params[:id])
  	@revisions = @doc.versions
  	
  	respond_to do |format|
  	  format.html
  	  format.json { render json: @doc }
  	end
  end
  
  def revert_revision
  
  	@doc = Doc.find(params[:id])
  	@lock_version = @doc.lock_version
  	@doc.revert_to(params[:version].to_i)
  	@doc.lock_version = @lock_version
  	@doc.updated_by = current_user.email
  	@doc.save
  	
  	redirect_to show_doc_revisions_path, :notice => "Successfully reverted to revision ##{params[:version]}."
  
  end
  
  def diff_content
  
  	@doc = Doc.find(params[:id])
  	@revision = Doc.find(params[:id])
  	@revision.revert_to(params[:revision].to_i)
  	
  	@doc.component = Differ.diff_by_word(@doc.component, @revision.component).format_as(:html)
  	@doc.contents = Differ.diff_by_line(@doc.contents, @revision.contents).format_as(:html)
  	
  	respond_to do |format|
  		format.html { render :layout => "site" }
  	end
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@doc.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
