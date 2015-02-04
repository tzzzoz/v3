class NetMessage < ActiveRecord::Base
  belongs_to :server  
  validates :server_id, :presence => true
end
