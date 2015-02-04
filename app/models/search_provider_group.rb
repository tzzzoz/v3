class SearchProviderGroup < ActiveRecord::Base
  belongs_to :provider
  belongs_to :search_provider_group_name
  
  validates :provider, :presence => true
  #validates :search_provider_group_name, :presence => true

end
