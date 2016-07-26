class DeliverablesController < ApplicationController
   
  layout "admin"
  
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
  
  # GET /deliverables
  # GET /deliverables.json
  def index
  	params[:search] ? @deliverables = Deliverable.search(params[:search]) : @deliverables = Deliverable.all
    @artifacts = Hash.new
    @deliverables.each do |d|
    	@artifacts[d.id] = Artifact.find_by_deliverable_id(d.id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deliverables }
    end
  end

  # GET /deliverables/1
  # GET /deliverables/1.json
  def show
    @deliverable = Deliverable.find(params[:id])
    @artifact = Artifact.find_by_deliverable_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deliverable }
    end
  end

  # GET /deliverables/new
  # GET /deliverables/new.json
  def new
    @deliverable = Deliverable.new
    @deliverable.build_artifact
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deliverable }
    end
  end

  # GET /deliverables/1/edit
  def edit
    @deliverable = Deliverable.find(params[:id])
  end

  # POST /deliverables
  # POST /deliverables.json
  def create
    @deliverable = Deliverable.new(params[:deliverable])

    respond_to do |format|
      if @deliverable.save
        format.html { redirect_to @deliverable, notice: "\"#{@deliverable.identifier}: #{@deliverable.description}\" was successfully created." }
        format.json { render json: @deliverable, status: :created, location: @deliverable }
      else
        format.html { render action: "new" }
        format.json { render json: @deliverable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /deliverables/1
  # PUT /deliverables/1.json
  def update
    @deliverable = Deliverable.find(params[:id])

    respond_to do |format|
      if @deliverable.update_attributes(params[:deliverable])
        format.html { redirect_to @deliverable, notice: "\"#{@deliverable.identifier}: #{@deliverable.description}\" was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @deliverable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliverables/1
  # DELETE /deliverables/1.json
  def destroy
    @deliverable = Deliverable.find(params[:id])
    @deliverable.destroy

    respond_to do |format|
      format.html { redirect_to deliverables_url }
      format.json { head :ok }
    end
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@deliverable.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
