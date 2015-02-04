class CreateAuthorizedCountries < ActiveRecord::Migration
  def self.up
    create_table :authorized_countries do |t|
      t.references :provider
      t.references :country
      t.timestamps
    end
  end

  def self.down
    drop_table :authorized_countries
  end
end
