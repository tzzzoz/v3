require "mysql2"

module MessageToMs

  class PutMessageRec
    def PutMessageRec.sendMessageRecord( message, param1 = "nil", param2 = "nil", param3 = "nil", param4 = "nil", param5 = "nil")
       client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
       client.query("use main_server")
       # field mfpa_id is autoincremented, field mfpa_done is set to -1 by default
       created_at = DateTime.now.to_formatted_s(:db)
       client.query("INSERT INTO MessageFromPA (mfpa_created_at, mfpa_message, mfpa_param1, mfpa_param2, mfpa_param3, mfpa_param4, mfpa_param5) VALUES (\"#{created_at}\", \"#{message}\", \"#{param1}\", \"#{param2}\", \"#{param3}\", \"#{param4}\", \"#{param5}\" )")
       client.close
     end
   end
  
end

