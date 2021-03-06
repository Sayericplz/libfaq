Libfaq::Application.routes.draw do

  get "dms/new"

  resources :faqs do
    get 'sift',:on=>:collection
    get 'firstpage',:on=>:collection
    get 'prepage',:on=>:collection
    get 'nextpage',:on=>:collection
    get 'lastpage',:on=>:collection
    get 'changepage',:on=>:collection
    get 'inputpage',:on=>:collection
    get 'stats',:on=>:collection
    get 'sift2',:on=>:collection
    get 'firstpage2',:on=>:collection
    get 'prepage2',:on=>:collection
    get 'nextpage2',:on=>:collection
    get 'lastpage2',:on=>:collection
    get 'changepage2',:on=>:collection
    get 'inputpage2',:on=>:collection
  end
  get "home/index"
  post "home/login"
  get "home/logout"
  root :to => "home#index"
  get "dms/index"
  match "dms/search"=>"dms#search"
  get "dms/show"
  get "dms/ask"
  get "dms/new"
  get "dms/firstpage"
  get "dms/prepage"
  get "dms/nextpage"
  get "dms/lastpage"
  post "dms/inputpage"
  #get "dms/changepage"
  match "dms/changepage"=>"dms#changepage"
  match "dms/create"=>"dms#create"
  match "dms/prompt"=>"dms#prompt"

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
  # match ':controller(/:action(/:id))(.:format)'
end
