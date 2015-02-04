class RemoveColumsToProvider < ActiveRecord::Migration
  def self.up
    remove_column :providers, :has_form
    remove_column :providers, :has_pdf
    remove_column :providers, :form_path
    remove_column :providers, :pdf_path
  end

  def self.down
    add_column :providers, :has_form, :boolean, :default => false
    add_column :providers, :has_pdf, :boolean, :default => false
    add_column :providers, :form_path, :string
    add_column :providers, :pdf_path, :string
  end

end
