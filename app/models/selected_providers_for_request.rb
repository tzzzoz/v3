class SelectedProvidersForRequest < ActiveRecord::Base
  belongs_to :provider
  belongs_to :request_to_provider
  
  validates :provider_id, :presence => true
  validates :request_to_provider_id, :presence => true
  
end
