class SearchStatsController < ApplicationController
layout "statistics"

before_filter :load_cached_search_params

  def index
  end

  def stid
    @search_st = SearchStat.where(:serv_name => params[:cs_name], :cs_stat_id => params[:s_s_id])

    respond_to do |format|
      format.xml { render :xml => @search_st }
      format.json { render json: @search_st }
    end
  end

  def create
    @sstat =  SearchStat.new(permitted_params)
    respond_to do |f|
      if @sstat.save
        f.xml  { render :xml => @sstat, :status => :created, :location => @sstat }
        f.json { render json: @sstat }
      else
        f.xml  { render :xml => @sstat.errors, :status => :unprocessable_entity }
        f.json { render json: @sstat.errors }
      end
    end
  end

  def update
  end

  def destroy
  end

  private

  def permitted_params
    params.require(:search_stat).permit!
  end

end
