ThinkingSphinx::Index.define(:statistic, :with => :active_record, :delta => true) do
  indexes user.login, :as => :user_login, :sortable => true
  indexes user.title.name, :as => :title_name, :sortable => true
  indexes image.provider.name, :as => :provider_name, :sortable => true
  indexes image.creator, :as => :creator, :sortable => true
  indexes image.headline, :as => :headline, :sortable => true
  indexes image.original_filename,:as => :original_filename,  :sortable => true
  indexes image.description, :as => :description
  indexes image.subject, :as => :subject

  # attributes
  has user_id, image_id, created_at
  has user.title_id, :as => :title_id
  has image.provider_id, :as => :provider_id, :facet => true
  has operation_label_id
end