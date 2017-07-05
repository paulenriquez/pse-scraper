class DataMarketStatus < ApplicationRecord
    before_validation GlobalModelMethods::SanitizationWrapper.new

    def get_cleansed_data
        hashed_data = {}
        self.attributes.each do |key, value|
            hashed_data[key.to_sym] = value
        end
        
        hashed_data[:last_updated] = get_last_updated
        
        [:total_volume, :total_trades, :total_value,
        :advances, :declines, :unchanged].each do |key|
            hashed_data[key] = hashed_data[key].gsub(/\s/, '').gsub(/\,/, '').to_f
        end
        
        hashed_data.delete(:created_at)
        hashed_data.delete(:updated_at)
        
        hashed_data
    end
    
    private
        def get_last_updated
            begin
                DateTime.strptime(
                    "#{self.last_updated.split(' ')[2..6].join(' ')} #{Time.zone.now.strftime('%z')}",
                    '%b %d, %Y %k:%M %p %z'
                ).strftime('%a, %d %b %Y %H:%M:%S')
            rescue
                self.last_updated
            end
        end
end
