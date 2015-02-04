class PermissionLabel < ActiveRecord::Base
  has_many :title_provider_groups, :through => :authorizations
  has_many :authorizations, :dependent => :destroy
  validates :label, :uniqueness => { :case_sensitive => false }
end
