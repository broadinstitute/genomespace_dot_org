class GuidesController < ApplicationController
  
  layout "admin"
  
  before_filter do 
  	authenticate_user!
  	authenticate_cms_admin
  end
  
  # GET /guides
  # GET /guides.json
  def index
    params[:search] ? @guides = Guide.search(params[:search]) : @guides = Guide.all
    # build a hash of all guide sections keyed by guide id
    @guide_sections = {}
    @guides.each do |g|
    	@guide_sections[g.id] = GuideSection.find_all_by_guide_id(g.id, :order => "display_order ASC")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guides }
    end
  end

  # GET /guides/1
  # GET /guides/1.json
  def show
    @guide = Guide.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guide }
    end
  end

  # GET /guides/new
  # GET /guides/new.json
  def new
    @guide = Guide.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guide }
    end
  end

  # GET /guides/1/edit
  def edit
    @guide = Guide.find(params[:id])
  end

  # POST /guides
  # POST /guides.json
  def create
    @guide = Guide.new(params[:guide])

    respond_to do |format|
      if @guide.save
        format.html { redirect_to @guide, notice: "\"#{@guide.title}\" was successfully created." }
        format.json { render json: @guide, status: :created, location: @guide }
      else
        format.html { render action: "new" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /guides/1
  # PUT /guides/1.json
  def update
    @guide = Guide.find(params[:id])

    respond_to do |format|
      if @guide.update_attributes(params[:guide])
        format.html { redirect_to @guide, notice: "\"#{@guide.title}\" was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guides/1
  # DELETE /guides/1.json
  def destroy
    @guide = Guide.find(params[:id])
    @guide.destroy

    respond_to do |format|
      format.html { redirect_to guides_url }
      format.json { head :ok }
    end
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@guide.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
