class Country < ActiveRecord::Base
  has_many :authorized_countries
  has_many :providers, :through => :authorized_countries

  has_many :titles, :dependent => :nullify
  has_many :title_provider_group_names

  validates :name, :presence => true, :uniqueness => { :case_sensitive => true }

end
