class PaniersController < ApplicationController

  layout "adm_agency"

  def create
    u = current_user.id
    Panier.create(:reportage_id => params[:id], :user_id => u) if Panier.where(:reportage_id => params[:id], :user_id => u).first.nil?
    @nb_panier = Panier.where(:user_id => u).count
#    clic_save(5,u,0)
  end

  def update
  end

  def destroy
    u = current_user.id
    Panier.where(:reportage_id => params["id"], :user_id => u).collect{|p| p.destroy}
#    clic_save(5,u,1)
    redirect_to(liste_reps_path(:panier => 1))
  end

  def index
  end

  def edit
  end

  def new
  end

  def show
  end

end