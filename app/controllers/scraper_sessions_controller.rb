class ScraperSessionsController < ApplicationController
    def api_get_status
        render json: ScraperSession.find_by(run_state: 'running').status
    end
    
end
