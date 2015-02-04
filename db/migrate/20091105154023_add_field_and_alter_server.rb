class AddFieldAndAlterServer < ActiveRecord::Migration
  def self.up
    change_table :servers do |t|
      t.column   :which_type, :string
      t.column   :is_self,    :boolean, :default => false, :null => false
      t.rename   :ip_adress,  :host
    end
  end

  def self.down
    change_table :servers do |t|
      t.remove   :which_type
      t.remove   :is_self
      t.rename   :host, :ip_adress
    end
  end
end
