class Admin::NeighborhoodsController < Admin::BaseController 
  layout 'admin'
  before_action :set_neighborhood, only: [ :show, :edit, :update, :destroy ]

  def index
    @neighborhoods = Neighborhood.alphabetical
  end

  def show
    @neighborhood = Neighborhood.includes(properties: { images_attachments: :blob })
                             .friendly.find(params[:id])
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)
    
    if @neighborhood.save
      redirect_to admin_neighborhoods_path, notice: 'Praia criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to admin_neighborhoods_path, notice: 'Praia atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @neighborhood.destroy
    redirect_to admin_neighborhoods_path, notice: 'Praia deletada com sucesso.'
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.friendly.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name)
  end
end