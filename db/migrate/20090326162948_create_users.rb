class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :login,  :limit => 40
      t.string :first_name,   :limit => 100, :default => '', :null => true
      t.string :last_name,   :limit => 100, :default => '', :null => true
      t.string :email,  :limit => 100
      t.string :crypted_password, :limit => 40
      t.string :salt,             :limit => 40
      t.string :activation_code,  :limit => 40
      t.string :remember_token, :limit => 40
      t.datetime :remember_token_expires_at, :activated_at
      t.integer :phone, :fax, :numero_tva, :default => 0
      t.string :company,  :limit => 40
      t.string :job,  :limit => 40
      t.string :activity_sector,  :limit => 60
      t.string :service,  :limit => 40
      t.string :billing_address, :billing_company, :city, :password_reset_code
      t.integer :zip_code
      t.text :permissions
      t.references :title, :role, :country
      t.timestamps
      # unique hash key to connect directly 
      # from a link without login/password. Must be generated
      # at account creation time
      t.string :login_key
      
    end
    add_index :users, :login,     :unique => true
    add_index :users, :login_key, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
