module TitlesHelper

  def get_restric(tpgn, prov)
    autho = {}
    prov.each do |p|
      tpg = TitleProviderGroup.where(title_provider_group_name_id: tpgn, provider_id: p)
      autho[p] = 0
      autho[p] = Authorization.where(title_provider_group_id: tpg.first.id).count + 1 unless tpg.blank?
    end
    autho
  end

end