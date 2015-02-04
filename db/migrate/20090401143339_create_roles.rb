class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name # 'superadmin', 'admin', 'user'
      t.text :permissions
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end