class LightBoxImagesController < ApplicationController
  def destroy
    @light_box = current_user.light_boxes.find(params[:id])
    light_box_image_ids = @light_box.light_box_images.select(:id).where(:image_id => params[:ids])
    light_box_image_ids.destroy_all
    init_html
    respond_to do |format|
     format.html { redirect_to full_screen_light_box_path(@light_box) }
     format.js { render 'light_boxes/show' }
    end
  end

  def update
    @light_box = current_user.light_boxes.find(session[:active_light_box])
    position = @light_box.light_box_images.order("position ASC").last[:position] unless @light_box.light_box_images.empty?
    position = 0 if position.nil?
    @light_box_ims_errors = []
    params[:ids].each do |i|
      position += 1
      err = @light_box.light_box_images.create({:image_id => i, :position => position })
      @light_box_ims_errors << err
    end
   @light_box_ims_errors.select!{|i| i.errors.any? }
   init_html
   render 'light_boxes/show'
  end

  def remove_for_good
    @light_box = current_user.light_boxes.find(params[:id])
    im = Image.find(params[:ids])
    Image.update(im.id, :content_error => true)
    respond_to do |format|
     format.html { redirect_to full_screen_light_box_path(@light_box) }
     format.js { render 'light_boxes/show' }
    end
  end

  private

  def init_html
    @lb_images = @light_box.images.where(:content_error => 0).order_by_light_box_position_desc.each
  end

end
