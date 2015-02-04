require "json"
require "net/http"
require "net/https"

class CreateSession
  attr_accessor :system_id, :system_pwd, :user_name, :user_pwd

  def initialize
    @endpoint = "https://connect.gettyimages.com/v1/session/CreateSession"
    @system_id = "10310"
    @system_pwd = "w0OfGxfMqLTZ3zKLymAJm/YKtJR80zauT2ZNzh78h4Q="
    @user_name = "pixtrakk_api"
    @user_pwd = "sm2q3n1lb2Fuxxz"
    GETTY_LOG.info "init OK"
  end

  def create_session
    request = {
        :RequestHeader =>
            {
                :Token => ""
            },
        :CreateSessionRequestBody =>
            {
                :SystemId => @system_id,
                :SystemPassword => @system_pwd,
                :UserName => @user_name,
                :UserPassword => @user_pwd
            }
    }


    response = post_json(request)



    @status = response["ResponseHeader"]["Status"]
    @token = response["CreateSessionResult"]["Token"]


    secure_token = response["CreateSessionResult"]["SecureToken"]
  end

  def post_json(request)
    #You may wish to replace this code with your preferred library for posting and receiving JSON data.
    uri = URI.parse(@endpoint)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true

    response = http.post(uri.path, request.to_json, {'Content-Type' =>'application/json'}).body
    JSON.parse(response)
  end
end