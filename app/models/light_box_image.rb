class LightBoxImage < ActiveRecord::Base
  belongs_to :image  
  belongs_to :light_box
  
  validates :light_box_id , :presence => true, :uniqueness => { :scope => :image_id }
  validate :check_max_images

def check_max_images
  maximg = max_lightbox_img
  if light_box.images.count >= maximg
    errors.add(:lb_overflow, I18n.t('too_many_in_light_box', :maxi => maximg))
    false
  else
    true
  end
end

def max_lightbox_img
    max_img = 50
    user =  UserSession.find.user
    max_img = 300 if user.is_provider_admin? || user.is_superadmin?

    max_img
end


end