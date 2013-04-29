Spree::Core::Engine.routes.draw do
  match '/admin' => 'admin/overview#index', :as => :admin

  get '/admin/analytics/sign_up' => 'admin/analytics#sign_up', :as => :admin_analytics_sign_up
  post '/admin/analytics/register' => 'admin/analytics#register', :as => :admin_analytics_register

  get '/jirafe' => 'admin/analytics#edit', :as => :admin_analytics
  put '/jirafe' => 'admin/analytics#update', :as => :admin_analytics
end
