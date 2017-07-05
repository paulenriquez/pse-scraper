class ScraperSessionsController < ApplicationController
    def launch
        if !ScraperSession.exists?(run_state: 'running')
           details = params[:details].to_s
            PseEdgeLaunchWrapper.new(
                "manual#{!details.empty? ? ' ' + details : ''}",
                Time.zone.now,
                nil
            )
            redirect_to pages_scraper_path, notice: 'Scraper session successfully launched.'
        else
            redirect_to pages_scraper_path, alert: 'Failed to launch manual session, there is a currently running session.'
        end
    end
end