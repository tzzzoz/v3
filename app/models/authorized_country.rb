class AuthorizedCountry < ActiveRecord::Base
  belongs_to :country
  belongs_to :provider
  
  validates :country_id, :presence => true
  validates :provider_id, :presence => true
end
