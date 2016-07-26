class MenuItemsController < ApplicationController
  
  layout "admin"
  
	before_filter do 
		authenticate_user!
		authenticate_cms_admin
	end
  	
  def index
  	@what_pages = MenuItem.find_all_by_category("what-is-genomespace", :order => "display_order ASC")
  	@tools_pages = MenuItem.find_all_by_category("tools", :order => "display_order ASC")
  	@doc_pages = MenuItem.find_all_by_category("documentation", :order => "display_order ASC")
  	@developer_pages = MenuItem.find_all_by_category("developers", :order => "display_order ASC")
  	@support_pages = MenuItem.find_all_by_category("support", :order => "display_order ASC")
  	@about_pages = MenuItem.find_all_by_category("about", :order => "display_order ASC")
  	
  	respond_to do |format|
  		format.html
  	end
  
  end
  
  def reorder_menu_items
  	@new_order = params[:menu_item]
  	i = 1
  	@new_order.each do |n|
  		menu_item = MenuItem.find(n)
  		menu_item.display_order = i
  		menu_item.save
  		i += 1
  	end
  	# need to reload arrays to fetch new order
  	@what_pages = MenuItem.find_all_by_category("what-is-genomespace", :order => "display_order ASC")
  	@tools_pages = MenuItem.find_all_by_category("tools", :order => "display_order ASC")
  	@doc_pages = MenuItem.find_all_by_category("documentation", :order => "display_order ASC")
  	@developer_pages = MenuItem.find_all_by_category("developers", :order => "display_order ASC")
  	@support_pages = MenuItem.find_all_by_category("support", :order => "display_order ASC")
  	@about_pages = MenuItem.find_all_by_category("about", :order => "display_order ASC")
  
  	respond_to do |format|
  		format.js
  	end
  end

end
