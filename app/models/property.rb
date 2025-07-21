class Property < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  friendly_id :title, use: :slugged
  
  belongs_to :neighborhood
  has_many_attached :images
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :neighborhood, presence: true
  
  # Validações opcionais para os novos campos
  validates :bedrooms, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :bathrooms, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :area_m2, numericality: { greater_than: 0 }, allow_blank: true
  validates :garage_spaces, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :property_type, inclusion: { 
    in: ['apartamento', 'cobertura', 'casa', 'casa_condominio', 'terreno', 'terreno_em_condominio', 'chacara', 'comercial'] 
  }, allow_blank: true
  
  validate :featured_limit
  
  scope :featured, -> { where(featured: true) }
  scope :not_featured, -> { where(featured: false) }
  
  # Novos scopes para busca
  scope :by_bedrooms, ->(bedrooms) { where(bedrooms: bedrooms) }
  scope :by_bathrooms, ->(bathrooms) { where(bathrooms: bathrooms) }
  scope :by_price_range, ->(min, max) { where(price: min..max) }
  scope :by_property_type, ->(type) { where(property_type: type) }
  scope :by_neighborhood, ->(neighborhood_id) { where(neighborhood_id: neighborhood_id) }
  scope :furnished_only, -> { where(furnished: true) }
  scope :with_garage, -> { where('garage_spaces > 0') }
  
  # Configuração do PgSearch para busca full-text
  pg_search_scope :search_by_keywords,
    against: {
      title: 'A',           # Peso A (mais importante)
      description: 'B'      # Peso B (menos importante)  
    },
    associated_against: {
      neighborhood: :name   # Busca também no nome do bairro
    },
    using: {
      tsearch: {
        prefix: true,       # Permite busca por prefixos
        dictionary: 'portuguese'
      }
    }
  
  # RANSACK - Atributos permitidos para busca (OBRIGATÓRIO para segurança)
  def self.ransackable_attributes(auth_object = nil)
    [
      "area_m2", "bathrooms", "bedrooms", "created_at", "description", 
      "featured", "furnished", "garage_spaces", "id", "neighborhood_id", 
      "price", "property_type", "title", "updated_at"
    ]
  end
  
  # RANSACK - Associações permitidas para busca
  def self.ransackable_associations(auth_object = nil)
    ["neighborhood", "images_attachments", "images_blobs"]
  end
  
  # Tipos de imóveis disponíveis
  PROPERTY_TYPES = [
    'Apartamento',
    'Cobertura', 
    'Casa',
    'Casa em Condomínio',
    'Terreno',
    'Terreno em Condomínio',
    'Chácara',
    'Comercial'
  ].freeze
  
  # Métodos para controlar limite de destaques (existentes)
  def self.featured_count
    featured.count
  end

  def self.can_add_featured?
    featured_count < 3
  end

  def can_be_featured?
    return true unless featured?
    self.class.can_add_featured? || featured_was
  end
  
  # Novos métodos úteis
  def area_formatted
    "#{area_m2.to_i} m²"
  end
  
  def bedrooms_bathrooms
    "#{bedrooms} dorm, #{bathrooms} banh"
  end
  
  def garage_info
    return "Sem garagem" if garage_spaces.zero?
    garage_spaces == 1 ? "1 vaga" : "#{garage_spaces} vagas"
  end

  private

  def featured_limit
    if featured? && !can_be_featured?
      errors.add(:featured, 'Máximo de 3 imóveis em destaque permitidos')
    end
  end
end