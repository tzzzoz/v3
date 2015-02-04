class AddPdfPathAndHasPdfToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :has_pdf, :boolean, :default => false
    add_column :providers, :pdf_path, :string
  end

  def self.down
    remove_column :providers, :has_pdf
    remove_column :providers, :pdf_path
  end
end
