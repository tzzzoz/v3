require 'machinist/active_record'
require 'sham'

Sham.define do
   email       { Forgery::Internet.email_address }
   first_name  { Forgery::Name.first_name }
   last_name   { Forgery::Name.last_name }
   login       { Forgery::Internet.user_name }
   password    { |index| "password_#{index}" }
   name        { |index| "#{Forgery::Basic.text}_#{index}" }
  
   # Server
   is_self(:unique    => false)     { true }
   status(:unique     => false)     { "public" }
   which_type(:unique => false)     { "ADMIN" }
  
   # Provider
   logo(:unique => false)           { "monlogo.jpg"}
   copyright_rule(:unique => false) { "\#{:creator}" }
   provider_conditions              { Forgery::Basic.text }
   string_key { |index| "mystring_#{index}" }

   # LightBoxPermissionLabel and PermissionLabel
   label(:unique => false)  { |index| "label_#{index}" }

end

User.blueprint do 
  login
  email
  password {"passss"}
  password_confirmation { password }
  first_name
  last_name 
  country # associated object
  title  # associated object
end

User.blueprint(:superadmin) do
  roles_mask(:unique => false) { 1 }
end

User.blueprint(:editor_admin) do
  roles_mask(:unique => false) { 2 }
end

User.blueprint(:editor_user) do
  roles_mask(:unique => false) { 4 }
end

User.blueprint(:provider_admin) do
  roles_mask(:unique => false) { 8 }
end

User.blueprint(:provider_user) do
  roles_mask(:unique => false) { 16 }
end

Country.blueprint do
   name { Forgery::Address.country }
end

Title.blueprint do
  name
  country # associated object
  server # associated object
end

Authorization.blueprint do
  title_provider_group # associated object
  permission_label # associated object
end

TitleProviderGroupName.blueprint do
  name
  country # associated object
end

TitleProviderGroup.blueprint do
  provider # associated object
  title_provider_group_name # associated object
  #authorizations # associated object
end

PermissionLabel.blueprint do
  label
  authorizations # associated object
end

Server.blueprint do
  is_self
  name
  status
  which_type
end

Provider.blueprint do
  name {|index| "#{Forgery::Name.company_name}_#{index}" }
  logo
  string_key
  copyright_rule
end

ProviderContact.blueprint do
  first_name
  last_name
  email
  provider # associated object
end

ProviderResponseToRequest.blueprint do
  image # associated object
  request_to_provider # associated object
end

RequestToProvider.blueprint do
  text { Forgery::Basic.text }
  user # associated object
end

SelectedProvidersForRequest.blueprint do
  provider
  request_to_provider
end

Image.blueprint do
  reception_date  { 1.hour.ago }
  date_created    { 1.hour.ago }
  thumb_location  { "/images/thumb.jpg"}
  medium_location { "/images/medium.jpg"}
  provider # associated object
  
end

LightBox.blueprint do
  name
  title # associated object
  user # associated object
end

LightBox.blueprint(:r) do
  name
  title # associated object
  user # associated object
  permission { 1 } # r
end

LightBox.blueprint(:rw) do
  name
  title # associated object
  user # associated object
  permission { 2 } # rw
end

LightBoxImage.blueprint do
  annotation { Forgery::Basic.text }
  light_box # associated object
  image # associated object
end

OperationLabel.blueprint do
  label 
end

SavedSearch.blueprint do
  name
  user # associated object
end

SearchProviderGroup.blueprint do
  provider # associated object
  search_provider_group_name # associated object
end

SearchProviderGroupName.blueprint do
  name
  user # associated object
end

Setting.blueprint do
  user # associated object
end

Statistic.blueprint do
  image # associated object
  user  # associated object
  operation_label # associated object
end