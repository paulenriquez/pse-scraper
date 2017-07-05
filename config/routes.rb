Rails.application.routes.draw do
  root to: 'pages#scraper'

  get '/about', to: 'pages#about', as: :pages_about
  scope '/scraper' do
    get '/', to: 'pages#scraper', as: :pages_scraper
    get '/configure_schedule', to: 'pages#scraper_configure_schedule', as: :pages_scraper_configure_schedule
    
    get '/session_launcher', to: 'pages#scraper_session_launcher', as: :pages_scraper_session_launcher
    post '/session_launcher', to: 'scraper_sessions#launch', as: :scraper_sessions_launch
  end
  scope '/database' do
     get '/', to: 'pages#database', as: :pages_database
     get '/:id', to: 'pages#database_show_session', as: :pages_database_show_session
     get '/export/:id', to: 'pages#database_export', as: :pages_database_export
  end
  
  scope '/api' do
    scope '/scraper' do
      get '/active_session', to: 'api#scraper_get_active_session'
      get '/validate_cron', to: 'api#scraper_get_validate_cron'
      get '/schedule', to: 'api#scraper_get_schedule'
    end
    scope '/database' do
      get '/table_preview', to: 'api#database_get_table_preview'
    end
    scope '/system' do
      get '/time', to: 'api#system_get_time'
    end
  end
  
  scope '/settings' do
    post '/set_schedule', to: 'settings#set_schedule', as: :settings_set_schedule
    post '/clear_schedule', to: 'settings#clear_schedule', as: :settings_clear_schedule
  end
end