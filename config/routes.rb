class MainSite
  def self.matches?(request)
    request.subdomain.blank? || request.subdomain == 'www' || request.subdomain == 'staging'
  end
end

Hipscan::Application.routes.draw do
  wiki_root '/qr-university'

  # Routes for the public site
  constraints MainSite do
    # Homepage
    root :to => 'welcome#index'
    
    # Account Signup Routes
    match '/signup' => 'accounts#plans', :as => 'plans'
    match '/signup/d/:discount' => 'accounts#plans'
    match '/signup/thanks' => 'accounts#thanks', :as => 'thanks'
    match '/signup/create/:discount' => 'accounts#create', :as => 'create', :defaults => { :discount => nil }
    match '/signup/:plan/:discount' => 'accounts#new', :as => 'new_account'
    match '/signup/:plan' => 'accounts#new', :as => 'new_account'
    match 'change-password' => 'accounts#password', :as => 'change_password'
    
    # Catch-all that just loads views from app/views/content/* ...
    # e.g, http://yoursite.com/content/about -> app/views/content/about.html.erb
    #
    match '/content/:action' => 'content'
    match '/u/:username' => 'mobile_sites#index'
    
  end

  # devise_for :saas_admins
  namespace "saas_admin" do
    root :to => "subscriptions#index"
    resources :subscriptions do
      member do
        post :charge
      end
    end

    resources :accounts
    resources :subscription_plans, :path => 'plans'
    resources :subscription_discounts, :path => 'discounts'
    resources :subscription_affiliates, :path => 'affiliates'
  end


  root :to => "accounts#dashboard"

  #
  # Account / User Management Routes
  #
  resource :account do 
    member do
      get :dashboard, :thanks, :plans, :canceled
      match :billing, :paypal, :plan, :plan_paypal, :cancel
    end
  end  
  
  ## END OF SUBSCRIPTIONS
  

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :skip => :registrations do
#    get "/", :to => "devise/registrations#new"
#    root :to => "home#index"
  end

  #  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :sessions => "users/sessions" }


  get "welcome/index"
  get "home/index"
  get 'home/color'
  get "home/unsubscribe", :as => 'unsubscribe'

  get "home/edit"
  post "home/update"
  put "home/update"
  match "home/sms"
  get "home/qr_to_facebook"
  get "home/analytics"
  get "home/analytics_map_data"
  get "home/analytics_map_data_world"
  get "home/mixpanel"

  match 'home' => 'home#index', :as => 'home'
  match 'home' => 'home#index', :as => 'user_root'

  get "facebook/index"
  get "facebook/test"
  match 'facebook' => 'facebook#index'

  match 'services' => 'welcome#services', :as => 'services'
  match 'services/video' => 'welcome#video_services', :as => 'video_services'
  match 'services/mobile' => 'welcome#mobile_services', :as => 'mobile_services'
  match 'services/design' => 'welcome#design_services', :as => 'design_services'
  match 'services/thankyou' => 'welcome#services_thankyou', :as => 'services_thankyou'
  match 'getinfo' => 'welcome#getinfo', :as => 'getinfo'

  match 'json/:username' => 'welcome#json'
  match 'json' => 'welcome#json'

  match 'myhipscan/:username' => 'welcome#myhipscan', :as => 'myhipscan'
  match 'myhipscan' => 'welcome#myhipscan'
  match 'qr/:username' => 'welcome#qr'

  match 'click/:user_id/:click_type' => 'welcome#click', :as => 'click'


  match 'about' => 'welcome#about'
  match 'qr-university' => 'welcome#qr_uni'
  match 'privacy_policy' => 'welcome#privacy_policy'
  match 'terms_of_use' => 'welcome#terms_of_use'
  match 'contact' => 'welcome#contact'
  match 'welcome/edit' => 'welcome#edit', :as => 'edit_welcome'
  match 'cms/update' => 'welcome#update', :as => 'update_welcome'

  match 'templates/new' => 'templates#new', :as => "new_template"
  match 'templates/export' => 'templates#export', :as => "export_template"
  match 'templates/:qr/form/:template' => 'templates#form', :as => "form_template"
  match 'templates/index/:qr/' => 'templates#index', :as => 'templates'
  match 'templates/create' => 'templates#create', :as => "create_template"
  match 'template/:qr' => 'templates#show', :as => 'template'
  match 'template/:qr/:template/page/:field' => 'templates#page', :as => 'template_page'
  match 'template/:qr/edit/:template' => 'templates#edit', :as => 'edit_template'
  match 'template/:qr/destroy/:template_item' => 'templates#destroy', :as => 'destroy_template_item'
  match 'template/:qr/update/:template' => 'templates#update', :as => 'update_template'

  

  #  post 'home/tweet'
  #  post 'home/wall'

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
  resources :qrs do
    member do
      get 'marketing'
      get 'edit_marketing'
      put 'update_marketing'
      get 'color'
      get 'analytics'
    end
  end

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

  # get "admin/index"
  # match "admin" => "admin#index"
  # namespace :admin do
  #  resources :users do
  #    get 'switch_to'
  #  end
  #  resources :scans
  #  resources :clicks
  #  resources :service_requests
  #  get 'incomplete'
  # end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to => "devise/registrations#new"
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'


  # Rails 3.0 bug

 # ckeditor_pictures GET    /ckeditor/pictures(.:format)              {:controller=>"ckeditor/pictures", :action=>"index"}
#                    POST   /ckeditor/pictures(.:format)              {:controller=>"ckeditor/pictures", :action=>"create"}
#   ckeditor_picture DELETE /ckeditor/pictures/:id(.:format)          {:controller=>"ckeditor/pictures", :action=>"destroy"}

#ckeditor_attachment_files GET    /ckeditor/attachment_files(.:format)      {:controller=>"ckeditor/attachment_files", :action=>"index"}
#                    POST   /ckeditor/attachment_files(.:format)      {:controller=>"ckeditor/attachment_files", :action=>"create"}
# ckeditor_attachment_file DELETE /ckeditor/attachment_files/:id(.:format)  {:controller=>"ckeditor/attachment_files", :action=>"destroy"}

 # post '/ckeditor/attachment_files', :as => 'ckeditor/attachment_files#create'
 # match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#destroy', :as => 'ckeditor_attachment_file'

 # match 'ckeditor/attachment_files' => 'ckeditor/attachment_files#index', :as => 'ckeditor_attachment_files'
 # match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#create', :via => :post
 # match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#destroy', :via => :delete, :as => 'ckeditor_attachment_file'
 # match 'ckeditor/pictures' => 'ckeditor/pictures#index', :as => 'ckeditor_pictures'
 # match 'ckeditor/picture' => 'ckeditor/pictures#create', :via => :post
 # match 'ckeditor/picture' => 'ckeditor/pictures#destroy', :via => :delete, :as => 'ckeditor_picture'


  # sneaky catch all, sets username to path
  match '*username', :to => 'welcome#missing_route'

  # match '*username' => 'welcome#index'
end
