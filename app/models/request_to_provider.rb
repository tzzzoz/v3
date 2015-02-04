class RequestToProvider < ActiveRecord::Base

  belongs_to  :user
  has_many :provider_response_to_requests, :dependent => :destroy
  has_many :selected_providers_for_requests, :dependent => :destroy
  has_many :providers, :through => :selected_providers_for_requests
  has_many :images, :through => :provider_response_to_requests
  has_many :reqphotos
  accepts_nested_attributes_for :reqphotos, :allow_destroy => true
  validates :user_id, :presence => true 
  
  def response_count
    provider_response_to_requests.count
  end

  def self.gen_serial(user_id)
    user = User.find_by_id(user_id.to_i)
    title = user.title.name
    server = user.title.server.name
    serial = "#{title}_#{server}_"
    5.times do
      rnd = rand(52)
      serial += (rnd > 25) ? rand(10).to_s : (65+rnd).chr
    end
    serial
  end

  def self.send_request(parameters)

    serial = self.gen_serial(parameters[:user])
    serial = self.gen_serial(parameters[:user]) while !RequestToProvider.find_by_serial(serial).nil?

    request = RequestToProvider.new(
      :text    => parameters[:request_text] ,
      :user_id => parameters[:user],
      :serial  => serial
    )
    user = User.find(parameters[:user])
    subject = "Requete depuis PixPalace de : #{user.login} #{user.title.name}"
    email_list=[]
    if request.save! && !parameters[:providers].nil?
      parameters[:providers].each do |provider_id|
        SelectedProvidersForRequest.create!(:provider_id => provider_id, :request_to_provider_id => request.id)
        provider_contacts = Provider.find(provider_id).provider_contacts.where(receive_requests: true)
        provider_contacts.each { |pc| email_list << pc.email }
      end
    end
  end

   def self.px_request(parameters)

    serial = self.gen_serial(parameters[:user]) while !RequestToProvider.find_by_serial(serial).nil?

    request = RequestToProvider.new(
      :text    => parameters[:request_text] ,
      :user_id => parameters[:user],
      :serial  => serial
    )
    user = User.find(parameters[:user])
    prov_str_key = []
    if request.save! && !parameters[:providers].nil?
      parameters[:providers].each do |provider_id|
        SelectedProvidersForRequest.create!(:provider_id => provider_id, :request_to_provider_id => request.id)
        prov_str_key << Provider.find(provider_id).string_key
      end

      Delayed::Job.enqueue( ForwardRequestJob.new(Server.find_by_is_self(true).id, parameters[:request_text], prov_str_key, user.login, serial), :locked_by => "comm_job" )

    end
   end

  def self.q_send_request(parameters)

    if parameters[:serial]
      serial = parameters[:serial]
    else
      serial = self.gen_serial(parameters[:user]) while !RequestToProvider.find_by_serial(serial).nil?
    end

    request = RequestToProvider.new(
      :text    => parameters[:request_text] ,
      :user_id => parameters[:user],
      :serial  => serial
    )
    user = User.find(parameters[:user])
    subject = "Requete depuis PixPalace de : #{user.login} #{user.title.name}"
    email_list=[]
    if request.save! && !parameters[:providers].nil?
      parameters[:providers].each do |p_str_key|
        prov = Provider.find_by_string_key(p_str_key)
        SelectedProvidersForRequest.create!(:provider_id => prov.id, :request_to_provider_id => request.id)
        provider_contacts = prov.provider_contacts.where(receive_requests: true)
        provider_contacts.each { |pc| email_list << pc.email }
      end

      #mail = UserMailer.deliver_send_request_to_provider((email_list rescue nil),"#{parameters[:request_text]}\nFTP dir : #{serial}", subject)
      mail = UserMailer.send_request_to_provider((email_list rescue nil),"#{parameters[:request_text]}\nFTP dir : #{serial}", subject).deliver
      #UserMailer.deliver(mail)
            #if Server.find_by_is_self(true).which_type == 'CS'
      #  mail = mail.to_yaml
      #  Server.find_by_which_type('ADMIN').net_messages.create({:message => "UserMailer.deliver(YAML::load(#{mail.dump}))", :skipable => true })
      #else
      #  UserMailer.deliver(mail)
      #end

    end
  end

end
