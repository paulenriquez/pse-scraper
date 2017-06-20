class AddJobMetadataToDelayedJob < ActiveRecord::Migration[5.0]
  def change
    add_column :delayed_jobs, :job_metadata, :json
  end
end
