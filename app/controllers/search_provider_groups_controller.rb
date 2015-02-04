class SearchProviderGroupsController < ApplicationController

  layout nil

#  def index
#    @groups = current_user.search_provider_group_names
#    # @search_provider_group_name = SearchProviderGroupName.first
#  end
#
#  # POST /search_provider_groups
#  # POST /search_provider_groups.xml
#  def create
#    if params[:providers]
#      @search_provider_group_name = SearchProviderGroupName.add_group(:name => params[:name],
#          :user_id    => current_user.id,
#          :providers  => params[:providers])
#      respond_to do |format|
#        if @search_provider_group_name.save
#          @groups = current_user.search_provider_group_names
#          format.xml  { render :xml => @groups.to_xml(:dasherize => false) }
#        else
#          format.xml  { render :text => "error" }
#        end
#      end
#    end
#  end
#
#  # PUT /search_provider_groups/1
#  # PUT /search_provider_groups/1.xml
#  def update
#    @search_provider_group = current_user.search_provider_group_names.find(params[:id])
#    respond_to do |format|
#      if @search_provider_group.update_attributes(:name => params[:name])
#        current_user.search_provider_group_names.update_group(:provider_group_name => @search_provider_group, :providers  => params[:providers])
#        @groups = current_user.search_provider_group_names
#        format.xml  { render :xml => @groups.to_xml(:dasherize => false) }
#      else
#        format.xml  { render :text => "error" }
#      end
#    end
#
#  end
#
#  # DELETE /search_provider_groups/1
#  # DELETE /search_provider_groups/1.xml
#  def destroy
#    @search_provider_group = current_user.search_provider_group_names.find(params[:id])
#    respond_to do |format|
#      if @search_provider_group.destroy
#        @groups = current_user.search_provider_group_names
#        format.xml  { render :xml => @groups.to_xml(:dasherize => false) }
#      else
#        format.xml  { render :text => "error" }
#      end
#    end
#  end
#
#  def show
#    @search_provider_group = current_user.search_provider_group_names.find(params[:id])
#  end
#
#  #def show
#  #  @search_provider_group = SearchProviderGroupName.find(params[:id])
#  #  if @search_provider_group.update_attributes(:name => params[:name])
#  #    SearchProviderGroupName.update_group(:provider_group_name => @search_provider_group, :providers  => params[:providers])
#  #    @groups = current_user.search_provider_group_names
#  #  end
#  #end
#
#  def new
#
#  end
end
