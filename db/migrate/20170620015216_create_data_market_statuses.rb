class CreateDataMarketStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :data_market_statuses do |t|
      t.integer :scraper_session_id
      
      t.string :last_updated
      
      t.string :total_volume
      t.string :total_trades
      t.string :total_value
      t.string :advances
      t.string :declines
      t.string :unchanged
      
      t.timestamps
    end
  end
end
