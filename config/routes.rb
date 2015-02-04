Pixpalace::Application.routes.draw do
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
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
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
  
  resources :saved_searches
  resources :settings
  resources :request_to_providers do
        collection do
          get 'cs_request'
        end
    end
  resources :light_boxes
  resources :light_box_images
  resources :full_screen_light_boxes
  resources :downloads do
      collection do
        get 'bnf_mail'
        get 'user_demand'
        get 'aka_demand'
      end
  end
  resources :search_provider_groups
  resources :search_provider_group_names
  resources :providers do
      collection do
        get 'provkey'
      end
    end
  resources :border_color_providers
  resource :user_session
  resources :title_provider_groups
  resources :searches
  resources :searchstat
  resources :countries
  resources :titles
  resources :servers
  resources :roles
  resources :media_exporters
  resources :operation_labels
  resources :light_box_permission_labels
  resources :user_password_resets
  resources :users do
    collection do
      get 'loggin'
    end
  end
  resources :statistics
  resources :search_stats do
      collection do
        get 'stid'
      end
    end
  resources :provider_for_search_stats
  resources :search_image_fields
  resources :images do
    collection do
      get :named
    end
  end
  resources :reportages
  resources :reportage_photos
  resources :paniers
  resources :analytics

  match '/medias' => 'medias#index', :via => :get, :as => :medias
  match '/home' => 'home#index', :via => :get, :as => :home
  match '/send_and_delete' => 'light_boxes#send_and_delete', :via => :get, :as => :send_and_delete
  match '/remove_for_good' => 'light_box_images#remove_for_good', :via => :get, :as => :remove_for_good
  match '/admin' => 'admin#index', :via => :get, :as => :admin
  match '/home/show_light_boxe' => 'home#show_light_boxe', :via => :get, :as => :show_light_boxe
  match '/providers_to_csv' => 'providers#index', :via => :get, :format => 'csv', :as => 'providers_to_csv'
  match '/titles_to_csv' => 'titles#index', :via => :get, :format => 'csv', :as => 'titles_to_csv'
  match '/medias_to_csv' => 'searches#index', :via => :get, :format => 'csv', :as => 'medias_to_csv'
  match '/users_to_xls' => 'users#export_xls', :via => :get, :format => 'xls', :as => 'users_to_xls'
  match '/feed' => 'home#feed', :via => :get, :as => :feed
  match '/bnf_form' => 'downloads#bnf_form', :via => :get, :as => :bnf_form
  match '/has_conditions' => 'downloads#has_conditions', :via => :get, :as => :has_conditions
  match '/change_language' => 'user_sessions#change_language', :via => :get, :as => :change_language
  match '/login' => 'user_sessions#create', :via => :get, :as => :login
  match '/logout' => 'user_sessions#destroy', :via => :get, :as => :logout
  match '/error' => 'user_sessions#error', :via => :get, :as => :error
  match '/denied' => 'user_sessions#denied', :via => :get, :as => :denied
  match '/password_forgotten' => 'user_password_resets#new', :via => :get, :as => :password_forgotten
  match '/password_reset' => 'user_password_resets#edit', :via => :get, :as => :password_reset
  match '/password_update' => 'user_password_resets#update', :via => :get, :as => :password_update
  match '/password_create' => 'user_password_resets#create', :via => :get, :as => :password_create
  match '/stats_to_csv' => 'statistics#index', :via => :get, :format => 'csv', :as => :stats_to_csv
  match '/stats_to_mail' => 'statistics#mail_downloads', :via => :get, :as => :mail_downloads
  match '/adm_agency' => 'adm_agency#index', :via => :get, :as => :adm_agency
  match '/remove_error' => 'pictures_control#edit', :via => :get, :as => :remove_error
  match '/adm_agency/pictures_control' => 'pictures_control#index', :via => [:get, :post], :as => :pictures_control
  # match '/search_stats' => 'search_stats#index', :via => :get, :as => :search_stats
  match '/adm_agency/rtp' => 'rtp#index', :via => [:get, :post], :as => :rtp
  match '/statistics' => 'statistics#index', :via => :get, :as => :searchstats
  match '/liste_reps' => 'reportages#liste', :via => :get, :as => :liste_reps
 # match '/return_pp' => 'return_pp#create', :as => :return_pp, :format => :json
  match '/admin_reps' => 'reportages#index', :via => :get, :as => :admin_reps
 # match '/manage_offre' => 'ws_create_offers', :as => :manage_offre, :format => :json
  match '/test_crop' => 'images#tst_jcrop', :via => :get, :as => :test_crop
  match '/valid_crop' => 'images#valid_crop', :via => :get, :as => :valid_crop
  match '/form_20min' => 'vingtmins/photo_20mins#new', :via => :get, :as => :form_20min
  match '/definitive_crop' => 'images#definitive_crop', :via => :get, :as => :definitive_crop
  match '/horby_send' => 'images#horby_send', :via => :get, :as => :horby_send
  match '/print_send' => 'images#print_send', :via => :get, :as => :print_send

  root :to => 'user_sessions#new'

  namespace "vingtmins" do
    resources :photo20mins
  end

  namespace "admin" do
    resources :servers, :countries, :providers, :title_provider_groups, :title_provider_group_names, :titles, :users
  end

  #namespace "statistics" do
  #  resources :titles, :users
  #end



  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
