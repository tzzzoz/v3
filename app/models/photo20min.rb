class Photo20min < ActiveRecord::Base

  belongs_to :user

  mount_uploader :photo, PhotoUploader
  validates :photo, :presence => true
  validates :user_id, :presence => true
  validates :description, :presence => true
  validates :credit, :presence => true
  validates :city, :presence => true
  #validates :date_photo, :presence => true
  validates :reportage, :presence => true
end