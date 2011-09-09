Isport::Application.routes.draw do
  resources :site_posts

  devise_for :users, :controllers => { :registrations => "registrations",:invitations   => "invitations" } do
    get 'invitations/resend/:id' => 'invitations#resend', :as => 'invitation_resend'
    get 'invitations/email' => 'invitations#email', :as => 'invite_email'
    
  end
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

  root :to => "welcome#index"

  resource :user, :only => [:edit, :update, :destroy] 
  controller :people do
    match 'show_friends' => :show_friends
    match 'event_invitees_select/:id' => :event_invitees_select, :as => "event_invitees_select",
          :constraints => { :id => /[1-9]\d*/}
    match 'grouop_invitees_select/:id' => :group_invitees_select, :as => "group_invitees_select",
          :constraints => { :id => /[1-9]\d*/}
    match 'choose_interests' => :choose_interests, :as => "choose_interests", :via => :post
    match '/people/edit_interests' => :edit_interests, :as => "edit_interests"
    match '/people/item_fans' => :random_item_fans, :as => "random_item_fans", :via => :post
  end

  match '/people/show_posts' => 'people#show_posts'
  match '/people/show_items' => 'people#show_items'
  match '/people/show_groups' => 'people#show_groups'
  match '/profile/update_profile' => 'profiles#update_profile'
  match '/people/show_person_events' => 'people#show_person_events'
  match '/people/show_person_profile' => 'people#show_person_profile'
  match '/people/edit_profile' => 'people#edit_profile',:as => 'edit_profile'
  match '/people/friend_select' => 'people#friend_select'
  resources :people

  controller :users do
    match 'getting_started' => :getting_started, :as => 'getting_started'
    match 'select_interests' => :select_interests, :as => 'select_interests'
    match 'select_interested_people' => :select_interested_people, :as => 'select_interested_people'
    match 'change_password'=> :change_password, :as => 'change_password'
    match 'update_password'=> :update_password, :as => 'update_password', :via => :put
    match 'online_user' => :online_user,:as => 'online_user'
  end

  match '/users/sign_in' => 'users#sign_in', :as => 'sign_in' 
  match '/users/sign_up' => 'users#sign_up', :as => 'sign_up'

  controller :items do
    match '/items/:id' => :show, :via => :get,
          :constraints => {:id => /[1-9]\d*/}
    match '/items/myitems' => :myitems, :as => 'myitems'
    match '/items/add_fan_ajax' => :add_fan_ajax, :as => 'add_fan_ajax'
    match '/items/remove_fan_ajax' => :remove_fan_ajax, :as => 'remove_fan_ajax'
  end

  controller :site_info do
    match "/site_info/new_feedback" => :new_feedback, :as => 'new_feedback', :via => :get
    match "/site_info/create_feedback" => :create_feedback, :as => 'create_feedback', :via => :post
    match "/site_info/feedbacks" => :feedbacks, :as => 'feedbacks', :via => :get
    match "/site_info/:info_type" => :site_info, :as => 'site_info', :via => :get,
          :constraints => { :info_type => /about|contact|service/ }
  end

  controller :site_admin do
    match '/site_admin' => :events_admin
    match '/site_admin/deny_event' => :deny_event, :as => 'deny_event', :via => :post
    match '/site_admin/pass_event' => :pass_event, :as => 'pass_event', :via => :post
    match '/site_admin/delete_event' => :delete_event, :as => 'delete_event', :via => :post
    match '/site_admin/deny_group' => :deny_group, :as => 'deny_group', :via => :post
    match '/site_admin/pass_group' => :pass_group, :as => 'pass_group', :via => :post
    match '/site_admin/delete_group' => :delete_group, :as => 'delete_group', :via => :post
    match '/site_admin/manage_feedbacks(/:status)' => :feedbacks_admin, :as => 'manage_feedbacks', :via => :get,
          :constraints => { :status=> /processed|not_processed/}
    match '/site_admin/manage_events(/:status)' => :events_admin, :as => 'manage_events', :via => :get,
          :constraints => { :status=> /all|to_be_audit|pass_audit|audit_failed/}
    match '/site_admin/manage_groups(/:status)' => :groups_admin, :as => 'manage_groups', :via => :get,
          :constraints => { :status=> /all|to_be_audit|pass_audit|audit_failed/}
    match '/site_admin/events_count' => :get_events_count_ajax, :as => 'events_count'
    match '/site_admin/groups_count' => :get_groups_count_ajax, :as => 'groups_count'
  end

  controller :home do
    match 'home' => :index, :as => 'home'
  end

  controller :welcome do
    match 'welcome' => :index, :as => 'welcome'
    match 'notice' => :notice, :as => 'notice'
  end
 
  controller :events do
    match '/events/:id' => :show, :via => :get,
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:city/(/district/:district_id)(/item/:item_id)(/:time)' => :filtered, :as => 'event_filter',
           :constraints => { :city => /nanjing|shanghai|beijing|suzhou|guangzhou|shenzhen|hangzhou/, 
                             :district_id => /[1-9]\d*/,
                             :item_id => /[1-9]\d*/,
                             :time => /today|week|weekends|next_month|month|alltime|((((19|20)(([02468][048])|([13579][26]))-02-29))|((20[0-9][0-9])|(19[0-9][0-9]))-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))/
                           }
          
    match '/events/mine(/:type)' => :my_events, :as => 'my_events',
          :constraints => { :type=> /joined|recommended|friend_joined|friend_recommended/ }
    match '/events/:id/edit/members' => :edit_members, :as => 'event_members',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/map' => :map, :as => 'event_map',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/home_map' => :home_map, :as => 'event_home_map',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/participants' => :participants, :as => 'participants',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/fans' => :references, :as => 'references',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/invite_friends' => :invite_friends, :as => 'new_event_invite',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/new/of_group/:group_id' => :new, :as => 'new_group_event',
          :constraints => { :id => /[1-9]\d*/}
    match '/events/:id/edit(/:new)' => :edit, :as => 'edit_event',
          :constraints => { :id => /[1-9]\d*/, :new => /new/}
    match '/events/:id/cancel' => :cancel, :as => 'cancel_event',
          :constraints => { :id => /[1-9]\d*/, :new => /new/}, :via => :post
    match '/events/:id/reaudit' => :apply_reaudit, :as => 'event_reaudit',
          :constraints => { :id => /[1-9]\d*/ } 
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

  controller :friends do
    match '/friends/invite' => :invite, :as => 'invite_friends_to_site'
    match '/friends/find' => :find, :as => 'find_interested_people'
  end

  controller :site_posts do
    match '/blog' => :index, :as => 'site_blog'
    match '/blog/:id' => :show, :as => 'site_blog_show',
          :constraints => { :id => /[1-9]\d*/}
  end


  controller :location do
    match '/locations/districts_of_city' => :districts_of_city, :as => 'districts_of_city'
  end
  
  controller :groups do
    match '/groups/:city/(/district/:district_id)(/item/:item_id)' => :filtered, :as => 'group_filter',
          :constraints => { :city => /nanjing|shanghai|beijing|suzhou|guangzhou|shenzhen|hangzhou/,
                            :district_id => /[1-9]\d*/,
                            :item_id => /[1-9]\d*/}
    match '/groups/:id/invite_friends' => :invite_friends, :as => 'new_group_invite',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/edit/members' => :edit_members, :as => 'edit_group_members',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/events' => :events, :as => 'group_events',
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/:id/edit(/:new)' => :edit, :as => 'edit_group',
          :constraints => { :id => /[1-9]\d*/, :new => /new/}
    match '/groups/:id/reaudit' => :apply_reaudit, :as => 'group_audit',
          :constraints => { :id => /[1-9]\d*/ } 
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
