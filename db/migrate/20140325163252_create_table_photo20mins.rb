class CreateTablePhoto20mins < ActiveRecord::Migration
  def self.up
    create_table :photo20mins, :force => true do |t|
      t.string :photo
      t.integer :user_id
      t.string :description
      t.string :credit
      t.string :city
      t.datetime :date_photo
      t.string :reportage
      t.string :keywords
      t.timestamps
    end
    add_index :photo20mins, :user_id
  end

  def self.down
    drop_table :photo20mins
  end
end
