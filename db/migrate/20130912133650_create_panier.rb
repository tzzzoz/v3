class CreatePanier < ActiveRecord::Migration
    def up
      create_table :paniers, :force => true do |t|
        t.integer :reportage_id,  :null => false
        t.integer :user_id, :null => false
      end
      add_index :paniers, :reportage_id
      add_index :paniers, :user_id
    end

    def self.down
      drop_table :paniers
    end
end
