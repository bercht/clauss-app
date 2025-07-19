class Admin::PropertiesController < Admin::BaseController
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  before_action :set_neighborhoods, only: [:new, :create, :edit, :update]

  def index
    @properties = Property.includes(:neighborhood, images_attachments: :blob).order(created_at: :desc)
  end

  def show
    # Carregar imóveis relacionados do mesmo bairro (excluindo o atual)
    @related_properties = @property.neighborhood
                                  .properties
                                  .where.not(id: @property.id)
                                  .limit(4)
                                  .order(:created_at)
  end

  def new
    @property = Property.new
    @neighborhoods = Neighborhood.alphabetical
  end

  def create
    @property = Property.new(property_params)
    
    Rails.logger.debug "=== DEBUG CREATE PROPERTY ==="
    Rails.logger.debug "Params recebidos: #{params.inspect}"
    Rails.logger.debug "Property params: #{property_params.inspect}"
    Rails.logger.debug "Property valid?: #{@property.valid?}"
    Rails.logger.debug "Property errors: #{@property.errors.full_messages}" unless @property.valid?
    
    if @property.save
      Rails.logger.debug "Property salva com sucesso! ID: #{@property.id}"
      redirect_to admin_property_path(@property), notice: 'Imóvel criado com sucesso!'
    else
      Rails.logger.debug "Falha ao salvar property: #{@property.errors.full_messages}"
      flash.now[:alert] = "Erro ao criar imóvel. Verifique os campos obrigatórios."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Separar imagens dos outros parâmetros
    attrs = property_params
    images = attrs.delete(:images)
    
    Rails.logger.debug "=== DEBUG UPDATE PROPERTY ==="
    Rails.logger.debug "Property params (sem imagens): #{attrs.inspect}"
    Rails.logger.debug "Novas imagens: #{images&.length || 0} arquivos"

    
    # Atualizar campos normais (sem imagens)
    if @property.update(attrs)
      # Anexar novas imagens (se houver) SEM remover as existentes
      if images.present?
        @property.images.attach(images)
        Rails.logger.debug "#{images.length} novas imagens anexadas. Total de imagens: #{@property.images.count}"
      end
      
      redirect_to admin_property_path(@property), notice: 'Imóvel atualizado com sucesso!'
    else
      Rails.logger.debug "Falha ao atualizar property: #{@property.errors.full_messages}"
      flash.now[:alert] = "Erro ao atualizar imóvel."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    redirect_to admin_properties_path, notice: 'Imóvel removido com sucesso!'
  end

  private

  def set_property
    @property = Property.friendly.find(params[:id])
  end

  def set_neighborhoods
    @neighborhoods = Neighborhood.alphabetical
  end

  def property_params
    params.require(:property).permit(
      :title, 
      :price, 
      :description, 
      :neighborhood_id, 
      :featured, 
      :bedrooms, 
      :bathrooms, 
      :area_m2, 
      :garage_spaces, 
      :property_type, 
      :furnished,
      images: []
    )
  end
end