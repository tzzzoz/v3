# encoding: utf-8

# TODO: remove role names
SUPER_ADMIN_ROLE_NAME    = 'superadmin'
ADMIN_ROLE_NAME          = 'admin'
# --
THUMB_PER_PAGE            = ['8','20', '40', '60', '80']
LIST_ROWS_PER_PAGE        = ['60', '100', '200']
PICTURES_PATH              = "/images/providers/"
PDF_PATH                   = "/providers/"
DPI                         = ['75', '100', '300']
MS                          = {'FRA' => 'ftp.pixpalace.com', 'LePoint' => '192.168.13.238', 'NouvelObs' => '192.168.11.28' }
FILECSVNAME                  = 'providers'
PASSWORD_VALIDITY_PERIOD      = 3.months
USERS_LIST_FILE           = "public/system/listing_Users_PixPalace.xls"
FEATURES_PATH             = "public/features/"

#MAX_LIGHTBOX_IMAGES = 50

#begin
#  # Put the name of the provider group (admin) instead of "TitleProviderGroupName.first.name"
#  group_name = TitleProviderGroupName.first.name
#  PROV_IDS_FOR_COUNT = TitleProviderGroupName.find_by_name(group_name).providers.collect{|p| p.id}
#rescue
#  PROV_IDS_FOR_COUNT = []
#end

PixPalaceContact      = {
  'FR'    => {:phone => '+33 1 53 69 02 36', :web => 'www.pixpalace.com', :mail => 'info@pixpalace.com', :address => '19, rue Béranger 75003 Paris'},
  'EN'    => {:phone => '+33 1 53 69 02 36', :web => 'www.pixpalace.com', :mail => 'info@pixpalace.com', :address => '19, rue Béranger 75003 Paris'},
  'CHINA' => {:phone => '+33 1 53 69 02 36', :web => 'www.pixpalace.com', :mail => 'info@pixpalace.com', :address => '19, rue Béranger 75003 Paris'}
}
PixPalaceMail         = {
  "fr" => PixPalaceContact['FR'][:mail],
  "en" => PixPalaceContact['EN'][:mail],
  "zh-CN" => PixPalaceContact['CHINA'][:mail]
}
RSS_PER_PAGE = 25
# Use :thumb or :medium
RSS_IMAGE_FORMAT = :thumb

DELETE_LOG   = ActiveSupport::Logger.new(File.join(Rails.root, 'log' ,'delete.log'))

#ThinkingSphinx::SphinxQL.functions!
#ThinkingSphinx::Middlewares::DEFAULT.delete ThinkingSphinx::Middlewares::UTF8
#Delayed::Worker::sleep_delay = 30
