class SearchProviderGroupNamesController < ApplicationController

  layout :false

  def show
    @search_provider_group_name = current_user.search_provider_group_names.find(params[:id])
  end

  def index
    @groups = current_user.search_provider_group_names
    @spgn_id = current_user.search_provider_group_names.find(params[:id]).id if (params[:id])
  end

  def new
    @search_provider_group_name = SearchProviderGroupName.new()
  end

  def create
     @search_provider_group_name = SearchProviderGroupName.new(permitted_params)
     @search_provider_group_name.user_id = current_user.id

     if @search_provider_group_name.save
       @search_provider_group_name.add_group(params[:providers].keys) if params[:providers]
#       clic_save(10, current_user.id, 0)
       redirect_to :action => :index, :id => @search_provider_group_name.id
     else
       @search_provider_group_name.errors.full_messages.join('\n')
     end
  end

  def edit
    @search_provider_group_name = current_user.search_provider_group_names.find(params[:id])
  end

  def update
    @search_provider_group_name = current_user.search_provider_group_names.find(params[:id])
    if @search_provider_group_name.update_attributes(permitted_params)
        @search_provider_group_name.update_group(params[:providers].keys) unless params[:providers].nil?
    end
#    clic_save(10, current_user.id, 1)
    redirect_to :action => :index, :id => @search_provider_group_name.id
  end
  
  def destroy
    @search_provider_group = current_user.search_provider_group_names.find(params[:id])
    @search_provider_group.destroy
#    clic_save(10, current_user.id, 2)
  end
  
  private
  
  def permitted_params
    params.require(:search_provider_group_name).permit(:name)
  end

end
