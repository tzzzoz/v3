class Authorization < ActiveRecord::Base
  belongs_to :title_provider_group
  belongs_to :permission_label
end
