class CreateReportages < ActiveRecord::Migration
  def up
    create_table :reportages, :force => true do |t|
      t.string :no_reportage,  :limit => 96
      t.string :string_key, :limit => 70
      t.integer :nb_photos, :default => 0
      t.integer :prem_photo, :null => false
      t.string :rep_titre, :limit => 192
      t.text :rep_texte
      t.date :rep_date
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :reportages, :no_reportage
    add_index :reportages, :string_key
    add_index :reportages, :rep_titre
    add_index :reportages, :rep_date
  end

  def self.down
    drop_table :reportages
  end
end
