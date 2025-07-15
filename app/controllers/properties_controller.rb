class PropertiesController < ApplicationController
  before_action :set_property, only: [:show]
  before_action :set_search_data, only: [:index]

  def index
    # Busca com Ransack
    @q = Property.includes(:neighborhood, images_attachments: :blob).ransack(params[:q])
    
    # Aplicar busca por palavras-chave se fornecida
    if params[:keywords].present?
      properties_with_keywords = Property.search_by_keywords(params[:keywords])
      @q.result = @q.result.merge(properties_with_keywords)
    end
    
    # Resultados sem paginação (por enquanto)
    @properties = @q.result(distinct: true)
                    .order(featured: :desc, created_at: :desc)
                    .limit(24) # Limite para não sobrecarregar a página
    
    # Para estatísticas
    @total_properties = @q.result.count
    @search_performed = search_params_present?
  end

  def show
    # Carregar imóveis relacionados do mesmo bairro (excluindo o atual)
    @related_properties = @property.neighborhood
                                  .properties
                                  .where.not(id: @property.id)
                                  .limit(4)
                                  .order(:created_at)
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end
  
  def set_search_data
    # Dados para os formulários de busca
    @neighborhoods = Neighborhood.joins(:properties)
                                .select('neighborhoods.*, COUNT(properties.id) as properties_count')
                                .group('neighborhoods.id')
                                .order(:name)
    
    @property_types = Property.distinct.pluck(:property_type).compact.sort
    
    # Faixas de preço sugeridas (baseadas nos dados reais)
    @price_ranges = [
      { label: 'Até R$ 300.000', min: 0, max: 300_000 },
      { label: 'R$ 300.001 - R$ 500.000', min: 300_001, max: 500_000 },
      { label: 'R$ 500.001 - R$ 800.000', min: 500_001, max: 800_000 },
      { label: 'R$ 800.001 - R$ 1.200.000', min: 800_001, max: 1_200_000 },
      { label: 'Acima de R$ 1.200.000', min: 1_200_001, max: Float::INFINITY }
    ]
  end
  
  def search_params_present?
    params[:q].present? || params[:keywords].present?
  end
end