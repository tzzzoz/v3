class Reqphoto < ActiveRecord::Base

  #attr_accessible :reqphoto_content_type, :reqphoto_file_name, :reqphoto_file_size, :reqphoto_updated_at, :request_to_provider_id
  belongs_to  :request_to_provider
  #has_attached_file :reqphoto, :styles => { :thumb => "150X150" }
end
