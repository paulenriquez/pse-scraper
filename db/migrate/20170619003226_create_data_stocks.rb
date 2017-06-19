class CreateDataStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :data_stocks do |t|
      t.integer :scraper_session_id
      
      t.string :ticker
      t.string :last_updated
      
      t.string :status
      t.string :issue_type
      t.string :isin
      t.string :listing_date
      t.string :board_lot
      t.string :par_value
      t.string :market_capitalization
      t.string :outstanding_shares
      t.string :listed_shares
      t.string :issued_shares
      t.string :free_float_level
      t.string :foreign_ownership_limit
      
      t.string :sector
      t.string :subsector
      
      t.string :last_traded_price
      t.string :previous_close_and_date
      t.string :change_and_percent_change
      t.string :opening_price
      t.string :day_high
      t.string :day_low
      t.string :average_price
      t.string :value
      t.string :volume
      t.string :fifty_two_week_high
      t.string :fifty_two_week_low
      
      t.string :pe_ratio
      t.string :sector_pe_ratio
      t.string :book_value
      t.string :pbv_ratio
      
      t.timestamps
    end
  end
end
