class CreateCommunicationInJobs < ActiveRecord::Migration
  def change
    create_table :communication_in_jobs do |t|
      t.string :job_source
      t.integer :job_source_job_id
      t.string :type
      t.text :params
      t.integer :done
      t.string :result

      t.timestamps
    end
  end
end
