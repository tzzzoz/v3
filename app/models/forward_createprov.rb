class ForwardCreateprov

  attr_accessor :s_s_id, :prov, :result

  def initialize( s_s_id, prov, result)
    @s_s_id = s_s_id
    @prov = prov
    @result = result
  end

  def perform
    ProviderForSearchStat.create(:search_stat_id => @s_s_id, :provider_id => @prov, :result => @result)
  end

end
