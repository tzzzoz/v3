class SearchesController < ApplicationController

   def index
     render :json => Image.search(:with =>  {:provider_id=>params[:id], :content_error => false}, :order =>'RAND()', :limit => 10).collect{|image| image.thumb_location}.to_json
  end


end
