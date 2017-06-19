class CreateDataIndices < ActiveRecord::Migration[5.0]
  def change
    create_table :data_indices do |t|
      t.integer :scraper_session_id
      
      t.string :index
      t.string :value
      t.string :change
      t.string :percent_change
      
      t.timestamps
    end
  end
end
