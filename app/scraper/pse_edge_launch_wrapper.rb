class PseEdgeLaunchWrapper
    # The LATEST_PSE_EDGE_LOGIC constant contains the class file of the Scraping
    # Algorithms being used, without the .rb extension.
    #
    # If a new scraping algorithm is going to be used, edit the value of this
    # variable.
    LATEST_PSE_EDGE_LOGIC = 'pse_edge_v1'
    
    
    # DO NOT MODIFY THE initialize() METHOD!
    def initialize(details = nil, start_on = nil, repeat = nil)
        "ScrapingAlgorithms::#{LATEST_PSE_EDGE_LOGIC.classify}".constantize.new(details, start_on, repeat).launch
    end
end