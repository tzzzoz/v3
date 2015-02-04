class TitleProviderGroupName < ActiveRecord::Base
  has_many :providers, :through => :title_provider_groups
  has_many :title_provider_groups, lambda { includes(:provider, :authorizations).order('providers.name') } , :dependent => :destroy

  has_many :titles

  belongs_to :country

  validates_presence_of :name
  validates_presence_of :country
  validates_associated :country
  validates_uniqueness_of :name, :scope => :country_id
  accepts_nested_attributes_for :title_provider_groups, :allow_destroy => true, :reject_if => :all_blank


  def add_provider(provider_params)
    group = TitleProviderGroup.new(:provider_id => provider_params[:id])
    if provider_params[:authorizations]
      provider_params[:authorizations].each do |authorization|
        group.authorizations << Authorization.create(:permission_label_id => authorization)
      end
    end
    title_provider_groups << group
  end

end
