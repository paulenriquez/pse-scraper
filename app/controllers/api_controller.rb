class ApiController < ApplicationController
    def scraper_get_active_session
        scraper_session = ScraperSession.find_by(run_state: 'running')
        render json: scraper_session != nil ? scraper_session : {}
    end
    def scraper_get_status
        scraper_session = ScraperSession.find_by(run_state: 'running')
        render json: scraper_session != nil ? scraper_session.status : {}
    end
end
