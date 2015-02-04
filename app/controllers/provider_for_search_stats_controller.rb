class ProviderForSearchStatsController < ApplicationController



  def create
    @pstat =  ProviderForSearchStat.new(permitted_params)
    respond_to do |f|
      if @pstat.save
        f.xml  { render :xml => @pstat, :status => :created, :location => @pstat }
        f.json { render json: @pstat }
      else
        f.xml  { render :xml => @pstat.errors, :status => :unprocessable_entity }
        f.json { render json: @pstat.errors }
      end
    end
  end

  private
  
  def permitted_params
    params.require(:provider_for_search_stat).permit!
  end

end
