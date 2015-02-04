class SavedSearchesController < ApplicationController

  layout :false
  #before_filter :load_cached_search_params, :only => [:new, :create]

  def index
    @saved_searches = current_user.saved_searches
    @sav_s_id = params[:id] if (params[:id])
#    clic_save(9, current_user.id, 0)
  end

  def new
    @saved_search = SavedSearch.new
  end

  def edit
    @saved_search = current_user.saved_searches.find(params[:id])
  end

  def create
    sirch = params[:search].chomp("?")
    @current_params = Rails.cache.read(sirch)
    @saved_search = SavedSearch.new(permitted_params.merge({:user_id => current_user.id, :date => DateTime.now, :criteria => @current_params}))
#    clic_save(9, current_user.id, 1)
    if @saved_search.save
      redirect_to :action => :index, :id => @saved_search.id
    else
      render  :action => :index
    end
  end

  def update
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.update_attributes(permitted_params)
#    clic_save(9, current_user.id, 2)
    redirect_to  :action => :index, :id => @saved_search.id
  end

  def destroy
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.destroy
#    clic_save(9, current_user.id, 3)
  end

  private

  def permitted_params
    params.require(:saved_search).permit(:name, :photos_count)
  end

end
