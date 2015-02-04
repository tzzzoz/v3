# class MetadataConversion < ActiveRecord::Base
# 
#   @h_iptc_to_image = {}
#   @h_eightbim_to_image = {}
#   
#   class << self
#      attr_accessor :h_iptc_to_image, :h_eightbim_to_image
#   end
# 
#   after_destroy do
#     self.class.h_iptc_to_image = {}
#     self.class.h_eightbim_to_image = {}
#   end
# 
#   after_save do
#     self.class.h_iptc_to_image = {}
#     self.class.h_eightbim_to_image = {}
#   end
# 
#   def self.iptc_to_image
#     where('iptc IS NOT NULL').select('iptc, image').each{|k| h_iptc_to_image[k.iptc] = k.image} if h_iptc_to_image.blank?  
#     h_iptc_to_image
#   end
# 
#   def self.eightbim_to_image
#     where('eightbim IS NOT NULL').select('eightbim, image').each{|k| h_eightbim_to_image[k.eightbim] = k.image} if  h_eightbim_to_image.blank?
#     h_eightbim_to_image
#   end
# 
# end

class MetadataConversion < ActiveRecord::Base

  after_destroy do
    MetadataConversion.delete_cache_class_variables([:@@_iptc_to_image, :@@_eightbim_to_image])
  end

  after_save do
    MetadataConversion.delete_cache_class_variables([:@@_iptc_to_image, :@@_eightbim_to_image])
  end

  def self.delete_cache_class_variables(c_vars)
    (self.class_variables & c_vars).each{|c| self.remove_class_variable c}
  end

  def self.iptc_to_image
    @@_iptc_to_image ||= {}
    where('iptc IS NOT NULL').select('iptc, image').each{|k| @@_iptc_to_image[k.iptc] = k.image} if @@_iptc_to_image.blank?
    @@_iptc_to_image
  end

  def self.eightbim_to_image
    @@_eightbim_to_image ||= {}
    where('eightbim IS NOT NULL').select('eightbim, image').each{|k| @@_eightbim_to_image[k.eightbim] = k.image} if @@_eightbim_to_image.blank?
    @@_eightbim_to_image
  end

end