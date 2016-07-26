class UsersController < ApplicationController
  
  layout "admin"
  
  before_filter do 
  	authenticate_user!
  	authenticate_super_admin
  end
  
  # GET /Users
  # GET /Users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /Users/1
  # GET /Users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /Users/new
  # GET /Users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /Users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /Users
  # POST /Users.json
  def create
  	@username = params[:user][:email].split("@")[0]
  	# create an initial password using email username and 4-digit random number
  	@password = @username + (1000 + rand(9000)).to_s
  	params[:user][:password] = @password
  	params[:user][:password_confirmation] = @password
  	
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
      	GenomespaceMailer.new_user_email(@user, @password, request.host_with_port).deliver
        format.html { redirect_to @user, notice: "Account was successfully created. An email will be delivered to #{@user.email} with instructions for resetting the temporary password." }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /Users/1
  # PUT /Users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Users/1
  # DELETE /Users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

end
