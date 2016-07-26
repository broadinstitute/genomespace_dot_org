GenomespaceNew::Application.routes.draw do
 
	mount Ckeditor::Engine => "/ckeditor"
	resources :server_properties
	match "sites/genomespacefiles/config/serverurl.properties" => "site#server_properties", :as => "view_server_properties"
	match "system-status/urgent(.format)" => "site#view_urgent_system_messages", :as => "view_urgent_system_messages"
	match "system-status/latest(.format)" => "site#view_system_message"
	match "system-status/:url" => "site#view_system_message", :as => "view_system_message", :constraints => {:url => /.*/} 
	match "system-status" => "site#view_system_messages", :as => "view_system_messages", :constraints => {:url => /.*/} 
  resources :system_messages

	post "slideshow_items/reorder_slideshow_items" => "slideshow_items#reorder_slideshow_items"
  resources :slideshow_items
  get "request_invite" => "site#request_invite", :as => "request_invite"
  post "request_invite" => "site#process_invite", :as => "process_invite"
  get "request_received" => "site#request_received", :as => "request_received"
  match "invites/send_registration_invite/:id" => "invites#send_registration_invite", :as => "send_registration_invite"
  post "invites/bulk_invites" => "invites#bulk_invites", :as => "bulk_invites"
  resources :invites

  match "pages/:id/show_revisions" => "pages#show_revisions", :as => "show_revisions"
	match "pages/:id/revert_revision/:version" => "pages#revert_revision", :as => "revert_revision"
  match "pages/diff_content/:id/revision/:revision" => "pages#diff_content", :as => "diff_page_content"
  resources :pages
  
  get "menu_items" => "menu_items#index", :as => "menu_items"
  post "reorder_menu_items/:category" => "menu_items#reorder_menu_items"
  
  resources :deliverables
  resources :tools
  
  match "guides/:guide_id/guide_sections/:id/show_revisions" => "guide_sections#show_revisions", :as => "show_guide_section_revisions"
  match "guides/:guide_id/guide_sections/:id/revert_revision/:version" => "guide_sections#revert_revision", :as => "revert_guide_section_revisions"
  match "guides/:guide_id/guide_sections/diff_content/:id/revision/:revision" => "guide_sections#diff_content", :as => "diff_guide_section_content"
  resources :guides do
  	resources :guide_sections
 		post "reorder_guide_sections" => "guide_sections#reorder_guide_sections"
 		post "nest_guide_section/:id" => "guide_sections#nest_guide_section"
 		post "denest_guide_section/:id" => "guide_sections#denest_guide_section"
  end
  
  match "docs/:id/show_revisions" => "docs#show_revisions", :as => "show_doc_revisions"
  match "docs/:id/revert_revision/:version" => "docs#revert_revision", :as => "revert_doc_revision"
  resources :docs
  match "docs/new/copy" => "docs#new", :as => "copy_doc"
  match "docs/diff_content/:id/revision/:revision" => "docs#diff_content", :as => "diff_doc_content"
	
	# post "blog/:id" => "site#create_comment", :as => "create_comment"
	match "blog/report_abuse/:id" => "site#report_abuse", :as => "report_abuse"
	get "blog(/:url)" => "site#view_blog", :as => "view_blog", :constraints => {:url => /.*/} 
	match "latest_news" => "site#latest_news", :as => "latest_news"
	# match "posts/:id/comments" => "posts#show_comments", :as => "show_comments"
	# delete "posts/:post_id/comments/:id" => "posts#delete_comment", :as => "delete_comment"
	resources :posts
	
	resources :highlights
	match "news(/:url)" => "site#view_highlights", :as => "view_highlights"
	
  devise_for :users
  resources :users
    
  match "replace_selected_item/:id" => "site#replace_selected_item", :as => "replace_selected_item" 
  match "get_other_slideshow_items/:offset" => "site#get_other_slideshow_items", :as => "get_other_slideshow_items"
  match "team" => "site#team", :as => "team"
  match "team/deliverables" => "site#deliverables", :as => "view_deliverables"
  get "team/deliverables_report/:quarter" => "site#deliverables_report", :as => "view_deliverables_report"
  post "team/deliverables_report/:quarter" => "site#process_deliverables_report", :as => "process_deliverables_report"
  get "register" => "site#register", :as => "register_account"
  post "register" => "site#process_registration", :as => "process_registration"
  get "support" => "site#support", :as => "support"
  post "support" => "site#genomespace_google_groups", :as => "support_google_groups"
 	post "support/api/:url" => "site#view_docs"
 	match "support/api/:url(?:rev=:version)" => "site#view_docs"
 	match "support/guides/:url/print" => "site#print_guide", :as => "print_guide"
 	match "recipes" => redirect("/support/guides/recipes")
 	match "support/guides/:url" => "site#view_guide"
 	match "support/guides/:url/sections/:display_url(?:rev=:version)" => "site#view_guide"
 	match "support/guides/:url/sections/:display_url/instructions" => "site#recipe_instructions"
 	match "support/tools(/:lookup_name)" => "site#tools", :as => "view_tools"
 	match "search" => "site#search", :as => "search"
 	match "search/google/:search" => "site#google_search", :as => "google_search"
 	post "route_action" => "application#route_action", :as => "route_action"
  match "admin" => "application#admin", :as => "admin"
  match "/:url(?:rev=:version)" => "site#view" 
  get "/" => "site#index", :as => "site"
  root :to => "site#index"
  match "*a" => "site#rescue_from_nil_page", :constraints => lambda{|req| req.env["REQUEST_PATH"] !~ /(ckeditor|assets)/ }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
