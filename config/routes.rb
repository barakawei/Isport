Isport::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :contacts
  resources :profiles
  resources :posts do
    resources :comments, :only => [:create, :destroy, :index]
  end
  resources :photos
  resources :requests
  resources :status_messages
  resources :comments
  resources :status_messages do
    resources :comments,:only => [ :create,:show ]
  end
  resources :notifications
  resources :conversations do
  resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'
  end
  
  resources :conversation_visibilities

  root :to => "home#index"

  resource :user, :only => [:edit, :update, :destroy] 
  controller :people do
    match 'show_friends' => :show_friends
    match 'event_invitees_select/:id' => :event_invitees_select, :as => "event_invitees_select",
          :constraints => { :id => /[1-9]\d*/}
    match 'grouop_invitees_select/:id' => :group_invitees_select, :as => "group_invitees_select",
          :constraints => { :id => /[1-9]\d*/}
  end

  match '/people/show_posts' => 'people#show_posts'
  match '/people/show_items' => 'people#show_items'
  match '/people/show_groups' => 'people#show_groups'
  match '/profile/update_profile' => 'profiles#update_profile'
  match '/people/show_person_events' => 'people#show_person_events'
  match '/people/show_person_profile' => 'people#show_person_profile'
  match '/people/edit_profile' => 'people#edit_profile'
  match '/people/friend_select' => 'people#friend_select'
  resources :people

  controller :users do
    match 'getting_started' => :getting_started, :as => 'getting_started'
  end

  match '/users/sign_in' => 'users#sign_in', :as => 'sign_in' 
  match '/users/sign_up' => 'users#sign_up', :as => 'sign_up'

  controller :items do
    match '/items/:id' => :show, :via => :get,
          :constraints => {:id => /[1-9]\d*/}
    match '/items/myitems' => :myitems, :as => 'myitems'
  end

  controller :home do
    match 'home' => :index, :as => 'home'
  end

  controller :welcome do
    match 'welcome' => :index, :as => 'welcome'
  end
  
  controller :events do
    match '/events/:id' => :show, :via => :get,
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:city/(/district/:district_id)(/item/:item_id)(/:time)' => :filtered, :as => 'event_filter',
           :constraints => { :city => /nanjing|shanghai|beijing/, :district_id => /[1-9]\d*/,
                             :item_id => /[1-9]\d*/,
                             :time => /today|week|weekends|next_month|month|alltime|((((19|20)(([02468][048])|([13579][26]))-02-29))|((20[0-9][0-9])|(19[0-9][0-9]))-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))/
                           }
          
    match '/events/mine(/:type)' => :my_events, :as => 'my_events',
          :constraints => { :type=> /joined|recommended|friend_joined|friend_recommended/ }
    match '/events/:id/edit/members' => :edit_members, :as => 'event_members',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/map' => :map, :as => 'event_map',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/invite_friends' => :invite_friends, :as => 'new_event_invite',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/new/of_group/:group_id' => :new, :as => 'new_group_event',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/edit(/:new)' => :edit, :as => 'edit_event',
          :constraints => { :id => /[1-9]\d*/, :new => /new/}
  end

  controller :involvements do
    match '/involvments/:id/invite' => :invite, :as => 'event_invite', 
          :constraints => { :id => /[1-9]\d*/}
  end

  controller :memberships do
    match '/memberships/:id/invite' => :invite, :as => 'group_invite',
          :constraints => { :id => /[1-9]\d*/}
  end

  controller :group_topics do
    match '/groups/:group_id/topics/:id/summary' => :summary, :as => 'topic_summary',
    :constraints => { :id => /[1-9]\d*/, :group_id => /[1-9]\d*/}
  end


  controller :location do
    match '/locations/districts_of_city' => :districts_of_city, :as => 'districts_of_city'
  end
  
  controller :groups do
    match '/groups/:city/(/district/:district_id)(/item/:item_id)' => :filtered, :as => 'group_filter',
          :constraints => { :city => /nanjing|shanghai|beijing/, :district_id => /[1-9]\d*/,
                            :item_id => /[1-9]\d*/}
    match '/groups/:id/invite_friends' => :invite_friends, :as => 'new_group_invite',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/edit/members' => :edit_members, :as => 'edit_group_members',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/events' => :events, :as => 'group_events',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/edit(/:new)' => :edit, :as => 'edit_group',
          :constraints => { :id => /[1-9]\d*/, :new => /new/}
  end 

  resources :groups do
    member do
      get 'members'
      get 'forum'
    end
    resources :memberships
    resources :topics, :controller => 'group_topics'
  end

  resources :events do
    resources :event_comments, :controller => 'event_comments' 
  end
  resources :contacts
  resources :profiles
  resources :posts
  resources :photos
  resources :requests
  resources :items
  resources :involvements



  resources :topics do
    resources :topic_comments, :controller => 'topic_comments'
  end


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
