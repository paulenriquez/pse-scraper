class CreateScraperSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :scraper_sessions do |t|
      t.datetime :launched_at
      t.string :launched_from
      
      t.json :scraper_service
      
      t.string :run_state

      t.json :performance_data
      t.json :status
      
      t.timestamps
    end
  end
end
