class PseEdgeLaunchWrapper
    LATEST_PSE_EDGE_LOGIC = 'pse_edge_v1'
    
    
    def initialize(details = nil, start_on = nil, repeat = nil)
        "ScrapingAlgorithms::#{LATEST_PSE_EDGE_LOGIC.classify}".constantize.new(details, start_on, repeat).launch
    end
end