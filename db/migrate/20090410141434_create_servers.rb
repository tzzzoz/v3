class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.string :status #public/private
      t.string :ip_adress
      t.string :name
      #t.string :country
      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
