class TitleProviderGroup < ActiveRecord::Base
  belongs_to :provider
  belongs_to :title_provider_group_name
  has_many :authorizations, :dependent => :destroy
  has_many :permission_labels, :through => :authorizations

  validates :provider_id, :presence => true, :uniqueness => { :scope => :title_provider_group_name_id  }
  validates :title_provider_group_name_id, :presence => true

  PermissionLabel.all.each do |pl|

      define_method pl.label do
        !authorizations.where(:permission_label_id => pl.id ).first.nil?
      end

      define_method "#{pl.label}=" do |val|
        auth_exists = !authorizations.where(:permission_label_id => pl.id).first.nil?
        if val == '1'
          #authorizations.build(:permission_label_id => pl.id) unless auth_exists
          authorizations.new(:permission_label_id => pl.id) unless auth_exists
        else
          authorizations.where(:permission_label_id => pl.id).first.destroy if auth_exists
        end
      end

  end

end