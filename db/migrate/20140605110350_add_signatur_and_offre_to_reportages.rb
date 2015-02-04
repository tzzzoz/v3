class AddSignaturAndOffreToReportages < ActiveRecord::Migration
  def change
    add_column :reportages, :signatur, :string, :limit => 96
    add_column :reportages, :offre, :boolean
  end
end
