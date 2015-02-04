class AddFormColumnsToProvider < ActiveRecord::Migration
 def self.up
    add_column :providers, :form_file_name,    :string
    add_column :providers, :form_content_type, :string
    add_column :providers, :form_file_size,    :integer
    add_column :providers, :form_updated_at,   :datetime
  end

  def self.down
    remove_column :providers, :form_file_name
    remove_column :providers, :form_content_type
    remove_column :providers, :form_file_size
    remove_column :providers, :form_updated_at
  end
end
