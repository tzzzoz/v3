class ProviderForSearchStat < ActiveRecord::Base

  belongs_to :search_stat
  validates :search_stat_id, :presence => true

  serialize :provs

  def self.envoi_user_searches
    s_k = []
    Provider.all.each{|p| s_k[p.id]=p.string_key}
    ProviderForSearchStat.all.each do |ps|
      ssid = ps.search_stat_id
      ps.provs.each do |k,v|
        Delayed::Job.enqueue ForwardProvSearchStat.new(ssid, s_k[k], v)
      end
    end
    SearchStat.all.collect{ |s| s.destroy }
  end


end
