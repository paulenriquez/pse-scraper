class CreateScraperSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :scraper_sessions do |t|
      t.datetime :launched_at
      t.string :details
      
      t.json :scraper_service
      t.text :data_tables, array: true, default: []
      
      t.string :run_state
      t.boolean :repeat

      t.json :performance_data
      t.json :status
      
      t.timestamps
    end
  end
end
