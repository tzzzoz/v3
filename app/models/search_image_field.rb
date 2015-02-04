class SearchImageField < ActiveRecord::Base

  belongs_to :search_stat
  validates :search_stat_id, :presence => true

  serialize :iptc

  def self.envoi_field_searches
    SearchImageField.all.each do |imf|
      ssid = imf.search_stat_id
      imf.iptc.each do |k,v|
        Delayed::Job.enqueue ForwardImageField.new(ssid, k, v)
      end
    end
  end


end
