class CreateScraperSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :scraper_sessions do |t|
      t.datetime :launched_at
      
      t.string :scrape_service
      t.json :metadata
      
      t.json :status
      
      t.timestamps
    end
  end
end