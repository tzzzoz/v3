class SearchProviderGroupName < ActiveRecord::Base
  belongs_to  :user
  has_many    :search_provider_groups
  has_many    :providers, :through => :search_provider_groups
  
  validates :name, :presence => true, :uniqueness => { :scope => :user_id, :case_sensitive => false }  
  validates :user_id, :presence => true
  
  def add_group(providers)
    search_provider_groups.create( providers.collect{|p| {:provider_id => p} } )
  end

  def update_group(providers)
    search_provider_groups.destroy_all
    search_provider_groups.create( providers.collect{|p| {:provider_id => p} } )
  end
  
  def self.update_group(params)
    group = params[:provider_group_name]
    group.search_provider_groups.destroy_all
    params[:providers].each do |provider|
      group.search_provider_groups << SearchProviderGroup.new(:provider_id => provider)
    end
    group
  end
  
end
