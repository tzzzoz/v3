class ProviderResponseToRequest < ActiveRecord::Base
  belongs_to :request_to_provider, :counter_cache => :responses_count
  belongs_to :image
  
  validates :image_id, :presence => true
  validates :request_to_provider_id, :presence => true
  
  default_scope { order('updated_at DESC') }
end
