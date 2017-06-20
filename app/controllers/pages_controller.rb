class PagesController < ApplicationController
    def index
        
    end
    def scraper
        
    end
    def database
        
    end
    def status
        render json: ScrapeSession.all
    end
end