include GlobalModelMethods
class DataIndex < ApplicationRecord
    before_validation GlobalModelMethods::SanitizationWrapper.new

    def get_cleansed_data
        hashed_data = {}
        self.attributes.each do |key, value|
            hashed_data[key.to_sym] = value
        end
        
        hashed_data[:change] = get_change
        hashed_data[:percent_change] = get_percent_change
        
        hashed_data[:value] = hashed_data[:value].gsub(/\s/, '').gsub(/\,/, '').to_f
        
        hashed_data.delete(:created_at)
        hashed_data.delete(:updated_at)
        
        hashed_data
    end
    
    private
        def get_percent_change
            begin
                raw_percent_change = self.percent_change.gsub(/\s/, '').gsub(/\,/, '')
                change_sign = (raw_percent_change.force_encoding('utf-8').ends_with?('▲') ? '+' : '-')
                "#{change_sign}#{raw_percent_change[0..-2]}".to_f
            rescue
                self.percent_change
            end
        end
        def get_change
            begin
                raw_change = self.change.gsub(/\s/, '').gsub(/\,/, '')
                get_percent_change < 0 ? "-#{raw_change}".to_f : raw_change.to_f
            rescue
                self.change
            end
        end
end