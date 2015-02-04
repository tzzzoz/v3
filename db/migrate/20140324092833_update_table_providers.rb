class UpdateTableProviders < ActiveRecord::Migration
  def up
    remove_column :providers, :new_logo_file_name
    remove_column :providers, :new_logo_content_type
    remove_column :providers, :new_logo_file_size
    remove_column :providers, :new_logo_updated_at
    remove_column :providers, :pdf_file_name
    remove_column :providers, :pdf_content_type
    remove_column :providers, :pdf_file_size
    remove_column :providers, :pdf_updated_at
    remove_column :providers, :form_file_name
    remove_column :providers, :form_content_type
    remove_column :providers, :form_file_size
    remove_column :providers, :form_updated_at
    add_column :providers, :pdf, :string
    add_column :providers, :formu, :string
  end

  def down
    add_column :providers, :new_logo_file_name
    add_column :providers, :new_logo_content_type
    add_column :providers, :new_logo_file_size
    add_column :providers, :new_logo_updated_at
    add_column :providers, :pdf_file_name
    add_column :providers, :pdf_content_type
    add_column :providers, :pdf_file_size
    add_column :providers, :pdf_updated_at
    add_column :providers, :form_file_name
    add_column :providers, :form_content_type
    add_column :providers, :form_file_size
    add_column :providers, :form_updated_at
    remove_column :providers, :pdf, :string
    remove_column :providers, :formu, :string
  end
end
