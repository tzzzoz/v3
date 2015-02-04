class SearchImageFieldsController < ApplicationController



  def create
    @fstat =  SearchImageField.new(permitted_params)
    respond_to do |f|
      if @fstat.save
        f.xml  { render :xml => @fstat, :status => :created, :location => @fstat }
        f.json { render json: @fstat }
      else
        f.xml  { render :xml => @fstat.errors, :status => :unprocessable_entity }
        f.json { render json: @fstat.errors }
      end
    end
  end

  private
  
  def permitted_params
    params.require(:search_image_field).permit!
  end


end
