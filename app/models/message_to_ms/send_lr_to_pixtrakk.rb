module MessageToMs

  class SendLrToPixtrakk
  
    def SendLrToPixtrakk.send(image_ms_id)
      PutMessageRec.sendMessageRecord( "SEND_TO_PT", image_ms_id )
    end
  end 
end
