# THIS IS THE TEMPLATE FOR A SCRAPING ALGORITHM.

# Name of the class must start with "ScrapingAlgorithms::".
# Class name must be the "classified" version of the file name.
# The file name of this file is "sample_scraping_algo.rb". Therefore,
# the name of this class if "SampleScrapingAlgo". This is important
# since Rails has a certain way of reading files. If the class name
# is inconsistent with the file name, the class won't be found.
class ScrapingAlgorithms::SampleScrapingAlgo < BaseScraperService
    
    # The SCRAPER_SERVICE constant contains data about the scraping algorithm.
    # The name key contains the name of this class through self.name.split('::')[1].
    # You can add other keys here such as version, date, or other metadata relevant
    # to this algorithm.
    SCRAPER_SERVICE = { 
        name: self.name.split('::')[1] 
    }
    
    # The DATA_TABLES constant is an array of the names of the tables in which the data
    # is going to be stored in. All models which will contain scraped data MUST start with the
    # "data_" prefix.
    #
    # E.g.: data_stocks, data_market_status, data_public_trasport_routes, & etc.
    DATA_TABLES = ['data_table_a', 'data_table_b', 'data_table_c']

    # DO NOT MODIFY THE initialize() method.
    # This calls the initialize_scraper_service() method from the
    # BaseScraperService class.
    def initialize(details = nil, start_on = nil, cron_exp = nil)
        initialize_scraper_service({
            scraper_service: SCRAPER_SERVICE,
            data_tables: DATA_TABLES,
            details: details,
            start_on: start_on,
            cron_exp: cron_exp
        })
    end
    
    private
        # Your scraping logic goes in the main() method. This method will be called
        # by the BaseScraperService in the Execute Scraper stage of the session
        # lifecycle.
        def main
            # Available in this class is the @current_session variable.
            # This can be used to tag scraped data records with its session
            # to create an association.
            #
            # E.g.:
            # data_public_transport_route = DataPublicTransportRoute.new
            # data_public_transport_route.scraper_session_id = @current_session.id
            # <-- code for scraping and storing data -->
            # data_public_transport_route.save
            
            # Additionally, the update_status() method from the BaseScraperService
            # can also be accessed here to update the session status.
            # 
            # E.g.
            # <-- loop that iterates through a set of web pages -->
            #   current_page_title = <-- function to get page title -->
            #   update_status("Scraping #{current_page_title}")
            # <-- end of loop code block -->
        end
end