class ReportagePhoto < ActiveRecord::Base

  belongs_to :reportage
  validates :reportage_id, :presence => true
  validates :photo_ms_id, :presence => true

  #after_create :send_json_photorep
#  before_destroy :destroy_json_photorep

  private

  def send_json_photorep
    rep = Reportage.find(self.reportage_id)
    unless rep.offre == 0
      reportage = {}
      reportage["norep"] = rep.no_reportage
      reportage["prov"] = rep.string_key
      reportage["photo"] = self.photo_ms_id
      reportage["rang"] = self.rang
      json_reportage = reportage.to_json
      json_filename = "photo_create_#{photo_ms_id}_feature_"+Time.now.strftime("%Y%m%d-%H%M%S")+".json"
      File.open(FEATURES_PATH+json_filename,'wb') do |f|
        f.write(json_reportage)
      end
    end
  end

  #def destroy_json_photorep
  #    reportage = {}
  #    reportage["id"] = self.reportage_id
  #    reportage["photo"] = self.photo_ms_id
  #    reportage["rang"] = self.rang
  #    json_reportage = reportage.to_json
  #    json_filename = "photo_destroy_#{photo_ms_id}_feature_"+Time.now.strftime("%Y%m%d-%H%M%S")+".json"
  #    File.open(FEATURES_PATH+json_filename,'wb') do |f|
  #      f.write(json_reportage)
  #    end
  #end

end

