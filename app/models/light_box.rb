require 'digest/sha1'
class LightBox < ActiveRecord::Base
  belongs_to :user
  belongs_to :title
  has_many   :light_box_images, :dependent => :destroy
  has_many   :images, :through => :light_box_images
  before_create :generate_hash_code
  after_destroy :recreate_first_light_box

  validates :name, :presence => true, :uniqueness => { :scope => :user_id, :case_sensitive => false }
  validates :user_id,  :presence => true
  validates :title_id, :presence => true

  # attr_accessible :name, :title_id


  # TODO: add stuff here for managing shared light_boxes
  # scope :authorized, lambda {|user_id| where(["user_id = ?", user_id]) }


  # def self.authorized_light_boxes_by_user(user_id)
  #   my_current_user = User.find_by_id(user_id)
  # 
  #   LightBox.where([
  #     "(light_box_permission_label_id IS NOT NULL AND user_id IN (?))",
  #     my_current_user.title.users.collect{|u| u.id},
  #     ]) unless my_current_user.blank?
  # 
  #   end

  def shared?
    permission > 0
  end

  def unshared!
    self.update_attribute(:permission, 0)  
  end

  def readable?
    permission == 1
  end

  def readable!
    self.update_attribute(:permission, 1)
  end

  def writable?
    permission == 2
  end

  def writable!
    self.update_attribute(:permission, 2)
  end


  def recreate_first_light_box
    if self.class.where(:user_id => self.user_id).count == 0
      self.class.create(:name     => I18n.t('light_box.name'), 
                        :title_id => self.title_id, 
                        :user_id  => self.user_id)
    end
  end

  private

  def generate_hash_code
    self.hash_code = "X#{Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}"
  end

end