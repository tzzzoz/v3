class CreateCommunicationOutJobs < ActiveRecord::Migration
  def change
    create_table :communication_out_jobs do |t|
      t.string :type
      t.text :params
      t.integer :done
      t.string :result

      t.timestamps
    end
  end
end
