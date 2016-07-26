class ServerPropertiesController < ApplicationController
  layout "admin"
  
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
  
  # GET /server_properties
  # GET /server_properties.json
  def index
    @server_property = ServerProperty.first

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @server_properties }
    end
  end

  # GET /server_properties/1
  # GET /server_properties/1.json
  def show
    @server_property = ServerProperty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @server_property }
    end
  end

  # GET /server_properties/new
  # GET /server_properties/new.json
  def new
  	unless ServerProperty.count > 0
	    @server_property = ServerProperty.new
		else
			redirect_to server_properties_path, alert: "There can only be one server properties file.  Please update the existing record." and return
		end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @server_property }
    end
  end

  # GET /server_properties/1/edit
  def edit
    @server_property = ServerProperty.find(params[:id])
  end

  # POST /server_properties
  # POST /server_properties.json
  def create
    @server_property = ServerProperty.new(params[:server_property])

    respond_to do |format|
      if @server_property.save
        format.html { redirect_to server_properties_path, notice: 'GenomeSpace server properties have successfully been created.' }
        format.json { render json: @server_property, status: :created, location: @server_property }
      else
        format.html { render action: "new" }
        format.json { render json: @server_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /server_properties/1
  # PUT /server_properties/1.json
  def update
    @server_property = ServerProperty.find(params[:id])

    respond_to do |format|
      if @server_property.update_attributes(params[:server_property])
        format.html { redirect_to server_properties_path, notice: 'GenomeSpace server properties have successfully been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @server_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /server_properties/1
  # DELETE /server_properties/1.json
  def destroy
    @server_property = ServerProperty.find(params[:id])
    @server_property.destroy

    respond_to do |format|
      format.html { redirect_to server_properties_url }
      format.json { head :no_content }
    end
  end
end
