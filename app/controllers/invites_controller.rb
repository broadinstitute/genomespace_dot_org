class InvitesController < ApplicationController
  
  layout "admin"
  
  before_filter do 
  	authenticate_user!
  	authenticate_cms_admin
  end
  
  # GET /invites
  # GET /invites.json
  def index
    @invites = Invite.all
    @sent = Invite.find_all_by_sent_invite(true).count
    @unsent = Invite.find_all_by_sent_invite(false).count

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invites }
    end
  end

  # GET /invites/1
  # GET /invites/1.json
  def show
    @invite = Invite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invite }
    end
  end

  # GET /invites/new
  # GET /invites/new.json
  def new
    @invite = Invite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @invite }
    end
  end

  # GET /invites/1/edit
  def edit
    @invite = Invite.find(params[:id])
  end

  # POST /invites
  # POST /invites.json
  def create
    @invite = Invite.new(params[:invite])

    respond_to do |format|
      if @invite.save
        format.html { redirect_to @invite, notice: "Invite for #{@invite.email} was successfully created." }
        format.json { render json: @invite, status: :created, location: @invite }
      else
        format.html { render action: "new" }
        format.json { render json: @invite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /invites/1
  # PUT /invites/1.json
  def update
    @invite = Invite.find(params[:id])

    respond_to do |format|
      if @invite.update_attributes(params[:invite])
        format.html { redirect_to @invite, notice: "Invite for #{@invite.email}was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @invite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invites/1
  # DELETE /invites/1.json
  def destroy
    @invite = Invite.find(params[:id])
    @invite.destroy

    respond_to do |format|
      format.html { redirect_to invites_url }
      format.json { head :ok }
    end
  end
  
  def send_registration_invite
  	@invite = Invite.find(params[:id])
  	GenomespaceMailer.send_registration_invitation(@invite).deliver
  	@invite.sent_invite = true
  	@invite.emailed = Time.now.to_s
  	@invite.save
  	
  	redirect_to invites_path, notice: "You have sent a registration invitation to #{@invite.email}."
  end
  
  def bulk_invites
    	
  	@invites_to_send = params[:send_bulk].keep_if{|k,v|v=="1"}.keys
  	@sent = Array.new
  	
  	@invites_to_send.each do |i|
  		invite = Invite.find(i)
  		GenomespaceMailer.send_registration_invitation(invite).deliver
  		@sent << invite.email
  		invite.sent_invite = true
  		invite.emailed = Time.now.to_s
  		invite.save
  	end
  	redirect_to invites_path, notice: "Registration invitations were sent to #{@sent}."
  end
end
