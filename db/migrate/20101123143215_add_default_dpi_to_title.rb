class AddDefaultDpiToTitle < ActiveRecord::Migration
  def self.up
    change_column_default :titles, :dpi, 75
  end

  def self.down
    change_column_default :titles, :dpi, nil
  end
end
