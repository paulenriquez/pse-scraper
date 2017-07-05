class DataStock < ApplicationRecord
    before_validation GlobalModelMethods::SanitizationWrapper.new
    
    def get_cleansed_data
        hashed_data = {}
        self.attributes.each do |key, value|
            hashed_data[key.to_sym] = value
        end
        
        hashed_data[:last_updated] = get_last_updated
        
        hashed_data.delete(:previous_close_and_date)
        hashed_data[:previous_close] = get_previous_close
        hashed_data[:previous_close_date] = get_previous_close_date
        
        hashed_data.delete(:change_and_percent_change)
        hashed_data[:change] = get_change
        hashed_data[:percent_change] = get_percent_change
        
        [:board_lot, :par_value, :market_capitalization, :outstanding_shares,
        :listed_shares, :issued_shares, :free_float_level, :foreign_ownership_limit,
        :last_traded_price, :opening_price, :day_high, :day_low, :average_price,
        :value, :volume, :fifty_two_week_high, :fifty_two_week_low].each do |key|
            if hashed_data[key].nil? == false
                hashed_data[key] = hashed_data[key].gsub(/\s/, '').gsub(/\,/, '').to_f
            end
        end
        
        hashed_data.slice(
            :id,
            :scraper_session_id,
            :ticker,
            :last_updated,
            :status,
            :issue_type,
            :isin,
            :listing_date,
            :board_lot,
            :par_value,
            :market_capitalization,
            :outstanding_shares,
            :listed_shares,
            :issued_shares,
            :free_float_level,
            :foreign_ownership_limit,
            :sector,
            :subsector,
            :last_traded_price,
            :previous_close,
            :previous_close_date,
            :change,
            :percent_change,
            :opening_price,
            :day_high,
            :day_low,
            :average_price,
            :value,
            :volume,
            :fifty_two_week_high,
            :fifty_two_week_low,
            :pe_ratio,
            :sector_pe_ratio,
            :book_value,
            :pbv_ratio
        )
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
        def get_previous_close
            begin
                self.previous_close_and_date.split('(')[0].to_f
            rescue
                self.previous_close_and_date
            end
        end
        def get_previous_close_date
            begin
                Date.strptime(
                    self.previous_close_and_date.split('(')[1].slice(0..-2),
                    '%b %d, %Y'
                ).strftime('%a, %d %b %Y')
            rescue
                self.previous_close_and_date
            end
        end
        def get_change
            begin
                raw_change = self.change_and_percent_change.split('(')[0].split(' ')
                change_sign = raw_change[0] == 'down' ? '-' : '+'
                "#{change_sign}#{raw_change[1]}".to_f
            rescue
                self.change_and_percent_change
            end
        end
        def get_percent_change
            begin
                self.change_and_percent_change.split('(')[1].strip.slice(0..-3).to_f
            rescue
                self.change_and_percent_change
            end
        end
end