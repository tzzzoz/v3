class Panier < ActiveRecord::Base

  belongs_to :reportage
  belongs_to :user
  validates :reportage_id, :presence => true
  validates :user_id, :presence => true

end
