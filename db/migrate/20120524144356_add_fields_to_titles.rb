class AddFieldsToTitles < ActiveRecord::Migration
  def self.up
    change_table  :titles do |t|
      t.column  :first_name,  :string,  :limit => 100,  :default => ""
      t.column  :last_name,   :string,  :limit => 100,  :default => ""
      t.column  :address,     :string,  :limit => 150,  :default => ""
      t.column  :zip_code,    :string,  :limit => 10,   :default => ""
      t.column  :city,        :string,  :limit => 150,  :default => ""
      t.column  :phone,       :string,  :limit => 20,   :default => ""
      t.column  :email,       :string,  :limit => 100,  :default => ""
      t.column  :comment,     :string,  :limit => 500,  :default => ""
      t.column  :visible,     :integer,                 :default => 0
    end
  end
  def self.down
    change_table  :titles do |t|
      t.remove  :first_name
      t.remove  :last_name
      t.remove  :address
      t.remove  :zip_code
      t.remove  :city
      t.remove  :phone
      t.remove  :email
      t.remove  :comment
      t.remove  :visible
    end
  end
end
