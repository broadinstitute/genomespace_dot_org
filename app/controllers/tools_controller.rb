class ToolsController < ApplicationController
  
  layout "admin"
  
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
	
  # GET /tools
  # GET /tools.json
  def index
  	params[:search] ? @tools = Tool.search(params[:search]) : @tools = Tool.all
    @help_links = Hash.new
    @tools.each {|tool| @help_links[tool.id] = HelpLink.find_all_by_tool_id(tool.id)}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tools }
    end
  end

  # GET /tools/1
  # GET /tools/1.json
  def show
    @tool = Tool.find(params[:id])
    @help_links = HelpLink.find_all_by_tool_id(@tool.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tool }
    end
  end

  # GET /tools/new
  # GET /tools/new.json
  def new
    @tool = Tool.new
    @tool.help_links.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tool }
    end
  end

  # GET /tools/1/edit
  def edit
    @tool = Tool.find(params[:id])
    @help_links = HelpLink.find_all_by_tool_id(@tool.id)
  end

  # POST /tools
  # POST /tools.json
  def create
    @tool = Tool.new(params[:tool])

    respond_to do |format|
      if @tool.save
        format.html { redirect_to @tool, notice: 'Tool was successfully created.' }
        format.json { render json: @tool, status: :created, location: @tool }
      else
        format.html { render action: "new" }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tools/1
  # PUT /tools/1.json
  def update
    @tool = Tool.find(params[:id])

    respond_to do |format|
      if @tool.update_attributes(params[:tool])
        format.html { redirect_to @tool, notice: 'Tool was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tools/1
  # DELETE /tools/1.json
  def destroy
    @tool = Tool.find(params[:id])
    @tool.destroy

    respond_to do |format|
      format.html { redirect_to tools_url }
      format.json { head :ok }
    end
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@tool.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
