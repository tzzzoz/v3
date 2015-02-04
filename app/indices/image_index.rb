ThinkingSphinx::Index.define(:image, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta) do
  indexes :title, :subject, :instructions, :creator, :city, :country
  indexes :headline, :credit, :source, :file_name, :description
  indexes :reportage, :normalized_credit
  indexes :rights, :category
  indexes :original_filename, :sortable => true
  # attributes
  has :ratio, :reception_date, :created_at, :updated_at, :private_image, :content_error
  has :fonds
  has :provider_id, :facet => true
  has "(((TO_DAYS(`images`.`date_created`) * 86400) + TIME_TO_SEC(`images`.`date_created`)) - (TO_DAYS('1970-01-01') * 86400) + (unix_timestamp(utc_timestamp()) - unix_timestamp()))",
    :as => :date_created, :type => :bigint
end