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
    def destroy
        @scraper_session = ScraperSession.find(params[:id])
        
        session_num = @scraper_session.session_num
        
        @scraper_session.data_tables.each do |table|
            scraped_data = table.classify.constantize.where(scraper_session_id: @scraper_session.id)
            scraped_data.destroy_all
        end
        @scraper_session.destroy
        redirect_to pages_database_path, notice: "Session # #{session_num} successfully deleted."
    end
end