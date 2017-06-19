class PseEdgeScrapeService
    @@is_running = false
    @@current_session = ''
    @@delayed_job_session_id = ''
 
    def launch(from = nil)
        @@current_session = ScraperSession.new
        
    end
    def is_running?
        
    end
    def current_session
        
    end
    
    private
        def run_scrape
            
        end
        def write_status(status)
            
        end
        
        def scrape_market_data
            
        end
        def scrape_index_data
            
        end
        def scrape_stock_data
            
        end
end