Rails.application.routes.draw do
  root to: 'pages#index'
  
  get '/index', to: 'pages#index', as: :pages_index
  get '/scraper', to: 'pages#scraper', as: :pages_scraper
  get '/database', to: 'pages#database', as: :pages_database
  get '/settings', to: 'pages#settings', as: :pages_settings
  
  scope '/api' do
    scope '/scraper' do
      get '/active_session', to: 'api#scraper_get_active_session'
      get '/status', to: 'api#scraper_get_status'
    end
  end
end
