class SlideshowItemsController < ApplicationController

	layout "admin"
	
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
		
  # GET /slideshow_items
  # GET /slideshow_items.json
  def index
    @slideshow_items = SlideshowItem.order("display_order ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slideshow_items }
    end
  end

  # GET /slideshow_items/1
  # GET /slideshow_items/1.json
  def show
    @slideshow_item = SlideshowItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slideshow_item }
    end
  end

  # GET /slideshow_items/new
  # GET /slideshow_items/new.json
  def new
    @slideshow_item = SlideshowItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slideshow_item }
    end
  end

  # GET /slideshow_items/1/edit
  def edit
    @slideshow_item = SlideshowItem.find(params[:id])
  end

  # POST /slideshow_items
  # POST /slideshow_items.json
  def create
    @slideshow_item = SlideshowItem.new(params[:slideshow_item])

    respond_to do |format|
      if @slideshow_item.save
        format.html { redirect_to @slideshow_item, notice: "\"#{@slideshow_item.title}\" was successfully created.".html_safe }
        format.json { render json: @slideshow_item, status: :created, location: @slideshow_item }
      else
        format.html { render action: "new" }
        format.json { render json: @slideshow_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slideshow_items/1
  # PUT /slideshow_items/1.json
  def update
    @slideshow_item = SlideshowItem.find(params[:id])

    respond_to do |format|
      if @slideshow_item.update_attributes(params[:slideshow_item])
        format.html { redirect_to @slideshow_item, notice: "\"#{@slideshow_item.title}\" was successfully updated.".html_safe }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @slideshow_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slideshow_items/1
  # DELETE /slideshow_items/1.json
  def destroy
    @slideshow_item = SlideshowItem.find(params[:id])
    @slideshow_item.destroy

    respond_to do |format|
      format.html { redirect_to slideshow_items_url }
      format.json { head :ok }
    end
  end
  
  def reorder_slideshow_items
  
  	@new_order = params[:slideshow_item]
  	i = 1
  	@new_order.each do |n|
  		menu_item = SlideshowItem.find(n)
  		menu_item.display_order = i
  		menu_item.save
  		i += 1
  	end
  	
  	@slideshow_items = SlideshowItem.order("display_order ASC")
  	
  	respond_to do |format|
  	  format.js
  	end
  end
end
