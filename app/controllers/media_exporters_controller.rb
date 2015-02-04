class MediaExportersController < ApplicationController
  
  # TODO : move to lightbox controller with PDF respond_to
  def show
    lightbox = LightBox.authorized_light_boxes_by_user(current_user.id).find{|l| l.id == params[:light_box_id].to_i}
    #lightbox = current_user.light_boxes.find(params[:light_box_id])
    @medias = lightbox.light_box_images.where(["image_id IN(?)", params[:selectedPictures]]).collect{|lightbox_image| lightbox_image.image}
    layout = params[:form_orientation] == "1" ? :landscape : :portrait
      
    @location = "medium_location"
    @image_size = 90
    @credit = params[:form_text]
    @lightbox_name = params[:light_box_name]
    prawnto :prawn => { :page_layout => layout }
  end
  
end
