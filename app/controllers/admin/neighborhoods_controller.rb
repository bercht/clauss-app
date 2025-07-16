class Admin::NeighborhoodsController < Admin::BaseController
  before_action :set_neighborhood, only: [ :show, :edit, :update, :destroy ]

def index
  @neighborhoods = Neighborhood.alphabetical
end

  def show
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)
    
    if @neighborhood.save
      redirect_to admin_neighborhoods_path, notice: 'Bairro criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to admin_neighborhoods_path, notice: 'Bairro atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @neighborhood.destroy
    redirect_to admin_neighborhoods_path, notice: 'Bairro deletado com sucesso.'
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.friendly.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name)
  end
end