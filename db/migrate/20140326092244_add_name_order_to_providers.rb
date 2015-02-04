class AddNameOrderToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :name_order, :string
  end
end
