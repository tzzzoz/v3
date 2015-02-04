# -*- encoding : utf-8 -*-
require 'pixways'
require 'json'

class WsCreateOffersController < ApplicationController

  skip_before_filter :login_required

  def create
logger.info "*** params = #{params.inspect}"
#    logi = marek_decrypt(params[:login])
    logi = params[:RequestHeader][:login]
    mdp = params[:RequestHeader][:pwd]
    etat = params[:RequestHeader][:etat]
    message = {}
    message["statut"] = "ok"
    message["rep_id"] = 0
    message["etat"] = etat
    prov = ProvToApi.find_by_login_and_mot_passe(logi, mdp)
    if prov.nil?
      message["statut"] = "Erreur : identification inconnue"
    else
      prov_id = Provider.find_by_string_key(prov.string_key).id
      case etat
        when "creation"
          logger.info "++++ etat = #{etat} prov = #{prov_id}  file = #{params[:ReportageItems][:premPhoto]}"
          prem_img = Image.where(:provider_id => prov.id, :original_filename => params[:ReportageItems][:premPhoto]).first
          if prem_img.nil?
            message["statut"] = "Erreur : premPhoto inconnue"
          else
            created = []
            created = params[:ReportageItems][:repDate].split("-")
            rep = Reportage.create(:string_key => prov.string_key, :no_reportage => "API", :rep_titre => params[:ReportageItems][:title], :rep_texte => params[:ReportageItems][:texte],
                  :rep_date => "#{created[2].to_i}-#{created[1].to_i}-#{created[0].to_i}",
                  :prem_photo => prem_img.ms_image_id, :signatur => params[:ReportageItems][:credit], :offre => 1)

            Reportage.update(rep.id, :nb_photos => record_photos(params[:photos], rep.id))
            message["rep_id"] = rep.id
          end
        when "modification"
          rep = Reportage.find_by_id(params[:ReportageItems][:repId])
          if rep.nil?
            message["statut"] = "Erreur : ID inconnu"
          else
            Reportage.update(rep.id, :rep_titre => params[:ReportageItems][:title]) unless params[:ReportageItems][:title].blank?
            Reportage.update(rep.id, :rep_texte => params[:ReportageItems][:texte]) unless params[:ReportageItems][:texte].blank?
            Reportage.update(rep.id, :signatur => params[:ReportageItems][:credit]) unless params[:ReportageItems][:credit].blank?
            unless params[:ReportageItems][:premPhoto].blank?
              prem_img = Image.where(:provider_id => prov_id, :original_filename => params[:ReportageItems][:premPhoto]).first
              unless prem_img.nil?
                Reportage.update(rep.id, :prem_photo => prem_img.ms_image_id)
              end
            end
            unless params[:ReportageItems][:repDate].blank?
              created = []
              created = params[:ReportageItems][:repDate].split("-")
              unless created[2].to_i < 1900
                Reportage.update(rep.id, :rep_date => "#{created[2].to_i}-#{created[1].to_i}-#{created[0].to_i}")
              end
            end
            unless params[:photos].empty?
              ReportagePhoto.where(:reportage_id => rep.id).collect{|rp| rp.destroy}
              Reportage.update(rep.id, :nb_photos => record_photos(params[:photos], rep.id))
            end
            message["rep_id"] = rep.id
          end
        when "suppression"
          rep = Reportage.find_by_id(params[:ReportageItems][:repId])
          if rep.nil?
            message["statut"] = "Erreur : ID inconnu"
          else
            rep.destroy
          end
        else
          message["etat"] = "Erreur etat inconnu : #{etat}"
      end
    end

    json_message = message.to_json
    respond_to do |format|
      format.json { render json: json_message }
    end
  end

  private

  def record_photos(photos, rep)
    rang = 0
    photos.each do |i|
      img = Image.find_by_original_filename(i)
      unless img.nil?
        ReportagePhoto.create(:reportage_id => rep, :photo_ms_id => img.ms_image_id, :rang => rang)
        rang += 1
      end
    end
    rang
  end

end
