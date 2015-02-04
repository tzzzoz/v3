class ReportagePhotosController < ApplicationController

  layout "adm_agency"

  def index
    @reportage = Reportage.find(params[:id])
    @photos = ReportagePhoto.where(:reportage_id => params[:id]).order(:rang).collect{|i| Image.find_by_ms_image_id(i.photo_ms_id)}
  end

  def update
    Reportage.update(params[:id], :prem_photo => params[:img_ids][0].to_i)
    redirect_to(:controller => 'reportages', :action => 'edit')
  end

  def destroy
    ms_id = params[:id]
    photo = ReportagePhoto.find_by_photo_ms_id(ms_id)
    rep = Reportage.find(photo.reportage_id)
    photo.destroy
    Reportage.update(rep.id, :prem_photo => ReportagePhoto.where(:reportage_id => rep.id).order(:rang).first.photo_ms_id) if rep.prem_photo == ms_id.to_i
    Reportage.update(rep.id, :nb_photos => rep.nb_photos-1)
    redirect_to("/reportages/#{rep.id}/edit")
  end

end