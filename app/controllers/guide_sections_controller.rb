class GuideSectionsController < ApplicationController

	layout "admin"
	
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end

  # GET /guide_sections
  # GET /guide_sections.json
  def index
  	@guide = Guide.find(params[:guide_id])
    @guide_sections = GuideSection.find_all_by_guide_id(params[:guide_id], :order => "display_order ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guide_sections }
    end
  end

  # GET /guide_sections/1
  # GET /guide_sections/1.json
  def show
  	@guide = Guide.find(params[:guide_id])
    @guide_section = GuideSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guide_section }
    end
  end

  # GET /guide_sections/new
  # GET /guide_sections/new.json
  def new
  	@guide = Guide.find(params[:guide_id])
    @guide_section = @guide.guide_sections.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guide_section }
    end
  end

  # GET /guide_sections/1/edit
  def edit
  	@guide = Guide.find(params[:guide_id])
    @guide_section = GuideSection.find(params[:id])
  end

  # POST /guide_sections
  # POST /guide_sections.json
  def create
  	@guide = Guide.find(params[:guide_id])
    @guide_section = GuideSection.new(params[:guide_section])

    respond_to do |format|
      if @guide_section.save
        format.html { redirect_to [@guide, @guide_section], notice: "\"#{@guide_section.title}\" was successfully created." }
        format.json { render json: [@guide, @guide_section], status: :created, location: [@guide, @guide_section] }
      else
        format.html { render action: "new" }
        format.json { render json: [@guide, @guide_section].errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /guide_sections/1
  # PUT /guide_sections/1.json
  def update
  	@special_alert = nil
  	@guide = Guide.find(params[:guide_id])
    @guide_section = GuideSection.find(params[:id])
    if @guide_section.has_children? && params[:guide_section][:published] == "0"
			params[:guide_section][:published] = "1"
			@special_alert = "Guide Sections with child sections cannot be unpublished.  Please move any child sections to other parts of this guide if you wish to unpublish this guide section."
		end
    respond_to do |format|
      if @guide_section.update_attributes(params[:guide_section])
        format.html { redirect_to [@guide, @guide_section], notice: "\"#{@guide_section.title}\" section was successfully updated.", alert: @special_alert}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: [@guide, @guide_section].errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guide_sections/1
  # DELETE /guide_sections/1.json
  def destroy
    @guide_section = GuideSection.find(params[:id])
    # save display order and parent id for use later in reordering sections
    @display_order = @guide_section.display_order
    @parent_id = @guide_section.parent_id
    @destroyed = @guide_section.id
    @guide_section.destroy
    
    @guide = Guide.find(params[:guide_id])
    @guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")
    # reorder sections so that there are no gaps unless the section just deleted was the last
    unless @display_order == @guide_sections.size
    	counter = 1
	    @guide_sections.each do |guide_section|
	    	guide_section.display_order = counter
	    	# if destroy section had children then denest all children one level
	    	guide_section.parent_id == @destroyed ? guide_section.parent_id = @parent_id : nil
	    	guide_section.save
	    	counter += 1
	    end
	  end

    respond_to do |format|
      format.html { redirect_to guide_guide_sections_url }
      format.json { head :ok }
    end
  end
  
  def show_revisions
  	@guide = Guide.find(params[:guide_id])
  	@guide_section = GuideSection.find(params[:id])
  	@revisions = @guide_section.versions
  	
  	respond_to do |format|
  	  format.html
  	  format.json { render json: [@guide, @guide_section] }
  	end
  
  end
  
  def revert_revision
  	@guide = Guide.find(params[:guide_id])
  	@guide_section = GuideSection.find(params[:id])
  	@lock_version = @guide_section.lock_version
  	@guide_section.revert_to(params[:version].to_i)
  	@guide_section.lock_version = @lock_version
  	@guide_section.updated_by = current_user.email
  	@guide_section.save
  	
  	redirect_to show_guide_section_revisions_path, notice: "Successfully reverted to revision ##{params[:version]}."
  
  end
  
  def diff_content
  
  	@guide = Guide.find(params[:guide_id])
  	@guide_section = GuideSection.find(params[:id])
  	@revision = GuideSection.find(params[:id])
  	@revision.revert_to(params[:revision].to_i)
  	
  	@guide_section.title = Differ.diff_by_word(@guide_section.title, @revision.title).format_as(:html)
  	@guide_section.content = Differ.diff_by_line(@guide_section.content, @revision.content).format_as(:html)
  	
  	respond_to do |format|
  		format.html { render :layout => "site" }
  	end
  
  end
  
  # reorders guide sections based on post from table.  gets an array of ids that is looped through to set order based on a counter (i).
  def reorder_guide_sections
  
  	@guide = Guide.find(params[:guide_id])
  	@new_order = params[:guide_section].collect {|n| n.to_i}
  	@sanitized_order = []
		@sanity_check = true
		while @new_order.first != nil && @sanity_check == true
			guide_section = GuideSection.find(@new_order.first)
			if !guide_section.parent_id.nil?
				@sanity_check = false
			elsif guide_section.has_children?
				@sanitized_order << @new_order.first
				@new_order.delete(@new_order.first)
				next_section = GuideSection.find(@new_order.first)
				children = guide_section.get_children
				# looks to see if the next section is at the root level, if so it moves children & sub children up en masse
				if next_section.parent_id.nil?
					children.each do |child|
						@sanitized_order << child.id
						@new_order.delete(child.id)
						if child.has_children?
							sub_children = child.get_children
							sub_children.each do |sub_child|
								@sanitized_order << sub_child.id
								@new_order.delete(sub_child.id)
							end
						end
					end
				# if the next section has the same parent id but is not in the right order, adjust as necessary
				elsif next_section.parent_id == guide_section.id 
					child_ids = children.collect(&:id)
					child_order = @new_order & child_ids
					child_order.each do |c|
						child = GuideSection.find(c)
						@sanitized_order << c
						@new_order.delete(c)
						if child.has_children?
							sub_children = child.get_children
							sub_child_ids = sub_children.collect(&:id)
							sub_child_order = @new_order & sub_child_ids
							sub_child_order.each do |sc|
								@sanitized_order << sc
								@new_order.delete(sc)
							end
						end
					end
				else
					@sanity_check = false
				end
			else # root level, no children
				@sanitized_order << @new_order.first
				@new_order.delete(@new_order.first)
			end
		end
		
		unless @sanity_check == false
			i = 1
			@sanitized_order.each do |new|
				guide_section = GuideSection.find(new)
				guide_section.display_order = i
				guide_section.save
				i += 1
			end
  	else
  		@flash_alert = "The specified order is invalid.  Please try again."
  	end
  	
  	@guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")  
  	
  	respond_to do |format|
  	  format.js
  	end
  end
  
  # sets parent_id of given guide_section to be the item before.  has checks to preserve correct nesting.
  def nest_guide_section
  
  	@guide = Guide.find(params[:guide_id])
  	@guide_section = GuideSection.find(params[:id])
		@before_section = GuideSection.find_by_display_order_and_guide_id(@guide_section.display_order - 1, @guide.id)
		unless @before_section.parent_id.nil?
			@before_section_parent = GuideSection.find(@before_section.parent_id)
		end
		# items are at the same level
		if @before_section.parent_id.nil? || @before_section.parent_id == @guide_section.parent_id
			@guide_section.parent_id = @before_section.id
		# item is at root and before_section is at 2nd level, get super parent id
		elsif !@before_section_parent.nil? && !@before_section_parent.parent_id.nil? && @guide_section.parent_id.nil?
			@guide_section.parent_id = @before_section_parent.parent_id
		# item is 1 level below 
		else
			@guide_section.parent_id = @before_section.parent_id
		end
		@guide_section.save
		
		@guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")  
		
		respond_to do |format|
		  format.js
		end
  end
  
  # removes appropriate parent_id from given guide_section and resets accordingly.
  def denest_guide_section
  
  	@guide = Guide.find(params[:guide_id])
  	@guide_section = GuideSection.find(params[:id])
		@before_section = GuideSection.find_by_guide_id_and_display_order(@guide.id, @guide_section.display_order - 1)
		@after_section = GuideSection.find_by_guide_id_and_display_order(@guide.id, @guide_section.display_order + 1)
		# checks if guide_section is the first child of a sub_section; important for reordering all other child sections later
		if @guide_section.first_child?
			@was_first_child = true
			@previous_parent_id = @guide_section.parent_id
		end
		unless @before_section.parent_id.nil?
			@before_section_parent = GuideSection.find(@before_section.parent_id)
		end
		# item before WAS the parent, now nesting under the before item's parent
		if @guide_section.parent_id == @before_section.id
			@guide_section.parent_id = @before_section.parent_id
		# items were both nested at same level, need to get super parent id (which may be nil)
		elsif @guide_section.parent_id == @before_section.parent_id
			@guide_section.parent_id = @before_section_parent.parent_id
		# catch all, will only get here if item before is nested higher or item before is at root level
		else
			@guide_section.parent_id = nil
		end
		# gotcha to make sure denesting hasn't broken child ordering, will reorder as necessary
		# the guide_section being denested should be moved after the list of child sections it previous was a part of
		unless @after_section.nil?
			if @before_section.has_children? || @after_section.parent_id != @guide_section.parent_id
				# affected_children are all guide_sections nested under the same parent as the before_section, minus the current guide_section
				affected_children = GuideSection.where("guide_id = ? and parent_id = ? and id != ?", @guide.id, @was_first_child == true ? @previous_parent_id : @before_section.parent_id, @guide_section.id).order("display_order ASC")
				# grab the display_order of the first affected guide_section to reorder all subsequent guide_sections by
				first_order = @was_first_child == true ? @guide_section.display_order : affected_children.first.display_order
				affected_children.each do |child|
					child.display_order = first_order
					child.save
					first_order += 1
					if child.has_children?
						sub_children = child.get_children
						sub_children.each do |sub_child|
							sub_child.display_order = first_order
							sub_child.save
							first_order += 1
						end
					end
				end
				unless affected_children.blank?
					@guide_section.display_order = first_order
					if @guide_section.has_children?
						children = @guide_section.get_children
						start_order = @guide_section.display_order
						children.each do |child|
							child.display_order = start_order + 1
							child.save
							start_order += 1
						end
					end
				end
			end
		end
		
		@guide_section.save
		@guide_sections = GuideSection.find_all_by_guide_id(@guide.id, :order => "display_order ASC")  
		
		respond_to do |format|
		  format.js
		end
  end
  
  protected 
  
  def correct_stale_object_version
  
  	@guide_section.reload.attributes = params[:page].reject do |attrb, value|
    	attrb.to_sym == :lock_version
    end
  end
end
