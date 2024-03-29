Isport::Application.routes.draw do

  get "authorization/oauth_create"
  get "authorization/oauth_destroy"
  match "/auth/connect" => "authorization#connect" 
  match "/auth/callback" => "authorization#oauth_create"
  match "/users/connect" => 'registration#oauth_new', :as => 'connect_to_weibo', :method => :post
  match "/account/bind" => 'authorization#bind_account', :as => 'account_bind'
  match "/authorization/bind_new_account" => 'authorization#bind_new_account', :as => 'bind_new_account'
  match "/authorization/bind_old_account" => 'authorization#bind_old_account', :as => 'bind_old_account'
  match "/authorization/skip_binding" => 'authorization#skip_bind', :as => 'skip_bind'
  match "/users/validate_email" => 'users#validate_email', :as => 'validate_email'
  match "/users/validate_email_exist" => 'users#validate_email_exist', :as => 'validate_email_exist'

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
  resources :pics do
    resources :pic_comments,:only => [ :create,:show]
  end

  controller :pic_comments do
    match '/pic_comments/:pic_id/show_more' => :show_more,:as => "pic_show_more_comments"
  end
  resources :requests
  controller :status_messages do
    match '/status_messages/pic_upload' => :pic_upload
    match '/status_messages/refresh' => :refresh
    match '/status_messages/refresh_update' => :refresh_update
    match '/status_messages/video/:id' => :show_post_video, :as => 'status_message_video',
          :constraints => { :topic_id => /[1-9]\d*/}
    match '/status_messages/read/:id' => :read_post, :as => 'read_post',
          :constraints => { :topic_id => /[1-9]\d*/}

  end
  resources :status_messages
  resources :status_messages do
    resources :comments,:only => [ :create,:show,:destroy ]
  end
  controller :notifications do
    match '/notifications/refresh_count' => :refresh_count
    match '/notifications/notifications_detail' => :notifications_detail
  end
  resources :notifications
  resources :conversations do
  resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'
  end
  
  resources :conversation_visibilities
  controller :comments do
    match '/comments/show_pic_comment' => :show_pic_comment
  end

  controller :item_topics do
    match '/item_topics(/:order)' => :index, :as => 'item_topics', :via => :get,
          :constraints => {:order => /order_by_time|order_by_hot/ }
    match '/item_topics/:target/:order' => :filter, :as => 'filter_item_topics',
          :constraints => { :target => /mine|friends|hot/, :oreder => /order_by_time|order_by_hot/ }
    match '/item_topics/search/:item_id(/:order)' => :search, :as => 'search_item_topic',
          :constraints => { :item_id => /[1-9]\d*/, :order => /order_by_time|order_by_hot/ }
    match '/item_topics/interested(/:order)' => :interested, :as => 'interested_topics',
          :constraints => {:order => /order_by_time|order_by_hot/ }
    match '/item_topics/by_friends(/:order)' => :friends, :as => 'friends_topics',
          :constraints => {:order => /order_by_time|order_by_hot/ }
    match '/item_topics/:id/show_posts' => :show_posts,:as => "show_topic_posts"
    match '/item_topics/:id/login_and_reply' => :login_and_reply,:as => "login_and_reply"
    match '/item_topics/recent_topics' => :recent_topics,:as => "recent_topics"
    match '/item_topics/related_topics/:topic_id' => :related_topics,:as => "related_topics",
          :constraints => { :topic_id => /[1-9]\d*/}
  end
  resources :item_topics

  resources :comments
  resources :pic_comments


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
    match '/people/item_fans(/:city)' => :random_item_fans, :as => "random_item_fans", :via => :post,
          :constraints => { :city => /[1-9]\d*/}
    match '/people/:id/show_posts' => :show_posts,:as => "show_person_posts"
    match '/people/show_items' => :show_items
    match '/people/show_groups' => :show_groups
    match '/people/update_profile' => :update_profile
    match '/people/:id/show_person_events' => :show_person_events,:as => "show_person_events"
    match '/people/show_person_profile' => :show_person_profile
    match '/people/edit_profile' => :edit_profile,:as => 'edit_profile'
    match '/people/friend_select' => :friend_select
    match '/people/:id/show_person_albums' => :show_person_albums,:as => "show_person_albums"
  end

  resources :people do
    resources :albums
  end

  controller :users do
    match 'getting_started' => :getting_started, :as => 'getting_started'
    match 'select_interests' => :select_interests, :as => 'select_interests'
    match 'select_interested_people' => :select_interested_people, :as => 'select_interested_people'
    match 'change_password'=> :change_password, :as => 'change_password'
    match 'update_password'=> :update_password, :as => 'update_password'
    match 'update_email'=> :update_email, :as => 'update_email'
    match 'online_user' => :online_user,:as => 'online_user'
    match 'account_setting' => :set_account, :as => 'set_account'
    match 'delete_auth' => :delete_auth, :as => 'delete_auth'
    match '/users/connent_error' => :weibo_already_binded_error, :as => 'bind_error' 
    match '/users/potential_interested_people' => :potential_interested_people, :as => 'potential_interested_people'
    match '/users/reset_new_item_notice' => :reset_new_item_notice, :as => 'reset_new_item_notice'
  end

  match '/users/sign_in' => 'users#sign_in', :as => 'sign_in' 
  match '/users/sign_up' => 'users#sign_up', :as => 'sign_up'

  controller :items do
    match '/items/:id' => :show, :via => :get,
          :constraints => {:id => /[1-9]\d*/}
    match '/items/myitems' => :myitems, :as => 'myitems'
    match '/items/add_fan_ajax' => :add_fan_ajax, :as => 'add_fan_ajax'
    match '/items/remove_fan_ajax' => :remove_fan_ajax, :as => 'remove_fan_ajax'
    match '/items/:id/show_posts' => :show_posts,:as => "show_item_posts",
          :constraints => {:id => /[1-9]\d*/}
    match '/items/:id/show_events' => :show_events,:as => "show_item_events",
          :constraints => {:id => /[1-9]\d*/}
    match '/items/:id/show_topics' => :show_topics,:as => "show_item_topics",
          :constraints => {:id => /[1-9]\d*/}
    match '/items/:id/show_groups' => :show_groups,:as => "show_item_groups",
          :constraints => {:id => /[1-9]\d*/}
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
    match '/site_admin/manage_users' => :users_admin, :as => 'manage_users'
    match '/site_admin/select_high_quality_user/:id' => :select_high_quality_user, :as => 'select_high_quality_user',
          :constraints => {:id => /[1-9]\d*/}
    match '/site_admin/cancel_high_quality_user/:id' => :cancel_high_quality_user, :as => 'cancel_high_quality_user',
          :constraints => {:id => /[1-9]\d*/}
    match '/site_admin/select_high_quality_event/:id' => :select_high_quality_event, :as => 'select_high_quality_event',
          :constraints => {:id => /[1-9]\d*/}
    match '/site_admin/cancel_high_quality_event/:id' => :cancel_high_quality_event, :as => 'cancel_high_quality_event',
          :constraints => {:id => /[1-9]\d*/}
    match '/site_admin/select_high_quality_group/:id' => :select_high_quality_group, :as => 'select_high_quality_group',
          :constraints => {:id => /[1-9]\d*/}
    match '/site_admin/cancel_high_quality_group/:id' => :cancel_high_quality_group, :as => 'cancel_high_quality_group',
          :constraints => {:id => /[1-9]\d*/}
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
    match '/events/search/:city/(/district/:district_id)(/item/:item_id)(/:time)' => :filtered, :as => 'event_filter',
           :constraints => { :city => /[1-9]\d*/,
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
    match 'upload_photos/:id' => :upload_event_pics, :as => 'upload_event_pic',
          :constraints => { :id => /[1-9]\d*/ } 
    match '/events/recent_events' => :recent_events,:as => "recent_events"
  end

  controller :pics do
    match 'submit_pics/:id' => :update_description, :as => 'update_description', :via => :post,
          :constraints => { :id => /[1-9]\d*/ } 
    match 'cancel_upload' => :batch_destroy, :as => 'batch_destroy', :via => :delete
    match 'paginate_pics/:album_id' => :paginate_pics, :as => 'paginate_pics',
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
    match '/friends/find(/:city)' => :find, :as => 'find_interested_people',
          :constraints => { :city => /[1-9]\d*/}
  end

  controller :site_posts do
    match '/blog' => :index, :as => 'site_blog'
    match '/blog/:id' => :show, :as => 'site_blog_show',
          :constraints => { :id => /[1-9]\d*/}
  end


  controller :location do
    match '/locations/districts_of_city' => :districts_of_city, :as => 'districts_of_city'
    match '/locations/cities_of_province' => :cities_of_province, :as => 'cities_of_province'
  end
  
  controller :groups do
    match '/groups/:id' => :show, :via => :get,
          :constraints => { :id => /[1-9]\d*/}
    match '/groups/search/:city/(/district/:district_id)(/item/:item_id)' => :filtered, :as => 'group_filter',
          :constraints => { :city => /[1-9]\d*/,
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
  controller :event_comments do
    match '/event_comments/:id' => :destroy,:via => :delete, :as => 'event_comments'
  end
  resources :contacts
  resources :profiles
  resources :posts
  resources :photos
  resources :pics
  resources :requests
  resources :items
  resources :involvements



  resources :topics do
    resources :topic_comments, :controller => 'topic_comments'
  end

  resources :albums do
    resources :pics 
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
