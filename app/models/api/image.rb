require 'active_resource'
module Api
  class Image < ActiveResource::Base
	  self.site = 'http://patrick:violette@192.168.200.48'
    self.format = :xml
  end
end