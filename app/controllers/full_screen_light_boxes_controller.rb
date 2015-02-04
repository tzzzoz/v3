class FullScreenLightBoxesController < ApplicationController

    before_filter :current_user_light_boxes
    after_filter :store_current_light_box, :except => :update

    layout "window"

    def create
      @light_box = current_user.light_boxes.new(:name => params[:name], :title => current_user.title)
      if @light_box.save
         redirect_to(:action => :show, :id => @light_box.id, :notice => I18n.t('successfully_updated'))
      else
        render :action => :show
      end
    end

    def index
      @light_box = current_user_light_boxes.last
      @title = I18n.t("viewer", :name => @light_box.name)
      @light_box_images = @light_box.images.where(:content_error => 0)
      render :action => :show, :id => @light_box.id
    end

    def show
      @light_box = LightBox.find(params[:id])
      redirect_to :action => :index if @light_box.nil?
      @title = I18n.t("viewer", :name => @light_box.name)
      if (params[:order_by_provider] == "true")
        @light_box_images = @light_box.images.where(:content_error => 0).order_by_provider_name
      else
        @light_box_images = @light_box.images.where(:content_error => 0).order_by_light_box_position_desc
      end
      render "show_print" if params[:print]
      @ids = params[:ids]
#      clic_save(3,current_user.id,3)
    end

    def destroy
       @light_box = current_user_light_boxes.find(params[:id])
       redirect_to :action => :show, :id => current_user_light_boxes.last.id if @light_box.destroy
    end

    def update
      unless params[:lbid].blank?
       unless params[:ids].blank?
        @light_box = current_user_light_boxes.find(params[:lbid])
        params[:ids].split(',').collect{ |i| @light_box.light_box_images.create( {:image_id => i.to_i}) }
        redirect_to(:action => :show, :id => @light_box.id, :notice => I18n.t('successfully_updated'))
       else
        redirect_to(:action => :show, :id => params[:lbid], :notice => "Pas d'images")
       end
      else
        @light_box = current_user_light_boxes.find(params[:id])
        if @light_box.update_attributes(permitted_params)
          redirect_to(:action => :show, :id => @light_box.id, :notice => I18n.t('successfully_updated'))
        else
          render :action => :edit
        end
      end
    end

    def edit
      @light_box = current_user_light_boxes.find(params[:id])
    end

    private

    def current_user_light_boxes
      @light_boxes ||= current_user.light_boxes
    end

    def store_current_light_box
      session[:active_light_box] = @light_box.id
    end

    def permitted_params
      params.require(:light_box).permit(:name)
    end
    
end
