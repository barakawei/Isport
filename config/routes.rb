Isport::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :contacts
  resources :profiles
  resources :posts
  resources :photos
  resources :requests
  resources :comments
  resources :items
  resources :involvements

  resources :conversations do
    resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'
  end
  
  resources :conversation_visibilities

  root :to => "home#index"
  resource :user, :only => [:edit, :update, :destroy] 
  controller :people do
    match 'friends_request' => :friends_request
    match 'show_friends' => :show_friends
  end

  match '/people/friend_select' => 'people#friend_select'
  resources :people

  controller :users do
    match 'getting_started' => :getting_started, :as => 'getting_started'
  end

  controller :contacts do
    match 'remove_friend' => :remove_friend
  end

  controller :items do
    match 'myitems' => :myitems, :as => 'myitems'
  end

  controller :events do
    match '/events/today(/:id)(/:sort)' => :events_today, :as => 'events_today', 
          :constraints => { :id => /[1-9]\d*/, :sort => /(by_starttime)|(by_popularity)/}
    match '/events/week(/:id)(/:sort)' => :events_in_this_week, :as => 'events_week', 
          :constraints => { :id => /[1-9]\d*/, :sort => /(by_starttime)|(by_popularity)/}
    match '/events/weekends(/:id)(/:sort)' => :events_at_weekends, :as => 'events_weekends', 
          :constraints => { :id => /[1-9]\d*/, :sort => /(by_starttime)|(by_popularity)/}
    match '/events/alltime(/:id)(/:sort)' => :events_all_time, :as => 'events_alltime', 
          :constraints => { :id => /[1-9]\d*/, :sort => /(by_starttime)|(by_popularity)/}
    match '/events/mine(/:type)' => :my_events, :as => 'my_events'
    match '/events/:date(/:id)(/:sort)' => :events_at_date_selected, :as => 'events_date_selected', 
          :constraints => { :id => /[1-9]\d*/, :sort => /(by_starttime)|(by_popularity)/,
                            :date => /((((19|20)(([02468][048])|([13579][26]))-02-29))|((20[0-9][0-9])|(19[0-9][0-9]))-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))/}
    match '/events/:id/edit/:target' => :edit, :as => 'edit_members',
          :constraints => { :id => /[1-9]\d*/ }
  end
  resources :events
  
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
