require 'builder'

class ForwardedRequestController < ApplicationController

    def create
      logger.info "*** #{params.inspect}"
      remJob = CommunicationInJob.new
      remJob.job_source = params[:forward_request][:cs_name]
      remJob.job_source_job_id = params[:forward_request][:message_id]
      remJob.params = params[:forward_request]
      remJob.type = "ForwardRequest"

      # TODO call pixadmin
      done_pixa = 100
      remJob.done = done_pixa
      remJob.result = "result from pixadmin"
      remJob.save
      @retVal = do_forwarded_request( params[:forward_request][:cs_name], params[:forward_request][:job_id], params[:forward_request][:request_title], params[:forward_request][:providers], params[:forward_request][:user_login], params[:forward_request][:serial_ftp] )
      @id_to_take = params[:forward_request][:message_id]

      @xml = Builder::XmlMarkup.new
      @xml.instruct! :xml, :version => "1.1", :encoding => "UTF-8"
      @xml.forward_lr_stat do
        @xml.id_req{@id_to_take}
        @xml.result{@retVal}
      end

      respond_to do |format|
        format.xml { render :xml => @xml }
      end
    end

end
