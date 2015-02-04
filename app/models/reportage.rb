class Reportage < ActiveRecord::Base

  validates :no_reportage, :presence => true
  validates :string_key, :presence => true
  validates :rep_date, :presence => true
  has_many :reportage_photos, :dependent => :destroy
  has_many :paniers, :dependent => :destroy

  paginates_per 25

  #after_update :send_json_rep
  #before_destroy :destroy_json_rep

  private

  def send_json_rep
    unless self.offre == 0
      reportage = {}
      reportage["string_key"] = self.string_key
      reportage["no_reportage"] = self.no_reportage
      reportage["prem_photo"] = self.prem_photo
      reportage["nb_photo"] = self.nb_photos
      reportage["rep_date"] = self.rep_date
      reportage["rep_titre"] = self.rep_titre
      reportage["rep_texte"] = self.rep_texte
      reportage["signatur"] = self.signatur
      json_reportage = reportage.to_json
      json_filename = "upd_feature_"+Time.now.strftime("%Y%m%d-%H%M%S")+".json"
      File.open(FEATURES_PATH+json_filename,'wb') do |f|
        f.write(json_reportage)
      end
    end
   end

  def destroy_json_rep
      reportage = {}
      reportage["string_key"] = self.string_key
      reportage["no_reportage"] = self.no_reportage
      reportage["rep_titre"] = self.rep_titre
      reportage["signatur"] = self.signatur
      json_reportage = reportage.to_json
      json_filename = "destroy_feature_"+Time.now.strftime("%Y%m%d-%H%M%S")+".json"
      File.open(FEATURES_PATH+json_filename,'wb') do |f|
        f.write(json_reportage)
      end
   end

end
