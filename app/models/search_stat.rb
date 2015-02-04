require "mysql2"

class SearchStat < ActiveRecord::Base

  belongs_to :user
  validates :user_id, :presence => true
  has_many :provider_for_search_stats, :dependent => :destroy
  has_many :search_image_fields, :dependent => :destroy


  def self.envoi_pixadmin
    SearchStat.all.each do |s|
      Delayed::Job.enqueue ForwardSearchStat.new(s.id, s.keyword, s.since, s.tri, s.date_pp_from, s.date_pp_to, s.date_photo_from, s.date_photo_to, s.format, s.result, User.find(s.user_id).login, s.created_at)
    end
  end


  def self.purge_adm
    # dctrls = Time.now.midnight - 5.day
    # dres = Time.now.midnight - 3.day
    # drtp = Time.now.midnight - 40.day
    # client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
    # client.query("use main_server")
    # puts "Purge Controles #{dctrls}"
    # client.query("delete FROM MessageToPA where mtpa_created_at < '#{dctrls}'")
    # client.close

    # puts "Purge Recherche Utilisateurs #{dres}"
    # SearchStat.where('cs_created < ?', dres).collect{|s| s.destroy}

    # puts "Purge Requete aux Agences #{drtp}"
    # RequestToProvider.where('updated_at < ?', drtp).collect{|s| s.destroy}
    # puts "Fin Purge #{Time.now}"
  end

end
