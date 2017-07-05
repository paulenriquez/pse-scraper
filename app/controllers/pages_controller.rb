class PagesController < ApplicationController
    def index
        
    end
    def scraper
    
    end
    def scraper_configure_schedule
        if !(Setting.all.empty? || Setting.first.scraper_schedule.empty?)
            @setting = Setting.first
            @no_schedule = false
        else
            @setting = Setting.new
            @no_schedule = true
        end
    end
    def scraper_session_launcher

    end
    def database
        @scraper_sessions = ScraperSession.where.not(
            'run_state=? OR run_state=?', 'initialized', 'running'
        ).order(launched_at: :desc).paginate(page: params[:page], per_page: 20)
    end
    def database_show_session
        @scraper_session = ScraperSession.find(params[:id])
    end
    def database_export
        @scraper_session = ScraperSession.find(params[:id])
        respond_to do |format|
            format.xlsx {render xlsx: 'database_export', filename: "session_#{params[:id].to_s}"}
        end
    end
    def about
        
    end
end