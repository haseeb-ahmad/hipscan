class MainSite
  def self.matches?(request)
    request.subdomain.blank? || ['www', 'm', 'mobile', 'staging'].any? {|subdomain| subdomain == request.subdomain }
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
    match 'mobile-login' => 'accounts#mobile_signin', :as => "mobile_login"

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
  match 'vcard/:username' => 'qrs#vcard', :as => 'vcard'
  match 'new-multi-url' => 'templates#multi_url', :as => 'multi_url_qr'

  match 'shareasale/postback' => 'accounts#shareasale'

  match 'click/:user_id/:click_type' => 'welcome#click', :as => 'click'

  match 'about' => 'welcome#about'
  match 'qr-uni' => 'welcome#qr_uni'
  match 'privacy_policy' => 'welcome#privacy_policy'
  match 'terms_of_use' => 'welcome#terms_of_use'
  match 'contact' => 'welcome#contact'
  match 'pricing' => 'welcome#pricing'
  match 'mobile_university' => 'welcome#mobile_university'
  match 'welcome/edit' => 'welcome#edit', :as => 'edit_welcome'
  match 'cms/update' => 'welcome#update', :as => 'update_welcome'

  # Templates routes
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

  resources :qrs do
    member do
      get 'marketing'
      get 'edit_marketing'
      put 'update_marketing'
      get 'color'
      get 'analytics'
    end
  end

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

  root :to => 'welcome#index'

  post '/ckeditor/attachment_files' => 'ckeditor/attachment_files#create'
  match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#destroy', :as => 'ckeditor_attachment_file'
  match 'ckeditor/attachment_files' => 'ckeditor/attachment_files#index', :as => 'ckeditor_attachment_files'
  match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#create', :via => :post
  match 'ckeditor/attachment_file' => 'ckeditor/attachment_files#destroy', :via => :delete, :as => 'ckeditor_attachment_file'
  match 'ckeditor/pictures' => 'ckeditor/pictures#create', :via => :post
  match 'ckeditor/pictures' => 'ckeditor/pictures#destroy', :via => :delete, :as => 'ckeditor_picture'
  match 'ckeditor/pictures' => 'ckeditor/pictures#index', :as => 'ckeditor_pictures'

  # sneaky catch all, sets username to path
  match '*username', :to => 'welcome#missing_route'

  # match '*username' => 'welcome#index'
end
