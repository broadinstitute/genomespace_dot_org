class SystemMessagesController < ApplicationController
  
	layout "admin"

	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
  
  # GET /system_messages
  # GET /system_messages.json
  def index
    @system_messages = SystemMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @system_messages }
    end
  end

  # GET /system_messages/1
  # GET /system_messages/1.json
  def show
    @system_message = SystemMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @system_message }
    end
  end

  # GET /system_messages/new
  # GET /system_messages/new.json
  def new
    @system_message = SystemMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @system_message }
    end
  end

  # GET /system_messages/1/edit
  def edit
    @system_message = SystemMessage.find(params[:id])
  end

  # POST /system_messages
  # POST /system_messages.json
  def create
    @system_message = SystemMessage.new(params[:system_message])

    respond_to do |format|
      if @system_message.save
        format.html { redirect_to @system_message, notice: 'System message was successfully created.' }
        format.json { render json: @system_message, status: :created, location: @system_message }
      else
        format.html { render action: "new" }
        format.json { render json: @system_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /system_messages/1
  # PUT /system_messages/1.json
  def update
    @system_message = SystemMessage.find(params[:id])

    respond_to do |format|
      if @system_message.update_attributes(params[:system_message])
        format.html { redirect_to @system_message, notice: 'System message was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @system_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /system_messages/1
  # DELETE /system_messages/1.json
  def destroy
    @system_message = SystemMessage.find(params[:id])
    @system_message.destroy

    respond_to do |format|
      format.html { redirect_to system_messages_url }
      format.json { head :ok }
    end
  end
end
