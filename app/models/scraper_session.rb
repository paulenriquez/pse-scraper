class ScraperSession < ApplicationRecord
    def get_records_count
        count = 0
        self.data_tables.each do |table|
            model = table.classify.constantize
            model.all.each do |record|
                if record.scraper_session_id == self.id
                   count += 1 
                end
            end
        end
        count
    end
    def get_time_elapsed
        if self.run_state == 'running'
            Time.zone.now.to_f - Time.parse(self.performance_data['time_start']).to_f
        elsif self.run_state == 'initialized'
            0
        else
            Time.parse(self.performance_data['time_end']).to_f - Time.parse(self.performance_data['time_start']).to_f
        end
    end
    
    def get_scraped_data
        result = {}
        self.data_tables.each do |table|
            model = table.classify.constantize
            session_data = model.where(scraper_session_id: self.id)
            record_set = []
            
            header = []
            session_data[0].get_cleansed_data.keys.each do |key|
                header.push(key)
            end
            record_set.push(header)
            
            session_data.each do |data|
                data = data.get_cleansed_data
                
                row = []
                data.keys.each do |key|
                    row.push(data[key])
                end
                
                record_set.push(row)
            end
            
            result[table.underscore[5..-1].split('_').map { |val| val.capitalize }.join(' ').classify] = record_set
        end
        result
    end
end