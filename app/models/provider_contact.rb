class ProviderContact < ActiveRecord::Base
  belongs_to :provider
  validates :email, :format => { :with => /\A\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+\z/ }, :if => lambda { !email.blank? }
  validates :provider_id, :presence => true, :on => :update
end
