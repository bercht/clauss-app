# db/seeds.rb
# Dados de exemplo para o sistema imobiliário clauss

# Limpar dados existentes (apenas em desenvolvimento)
if Rails.env.development?
  puts "🧹 Limpando dados existentes..."
  Property.destroy_all
  Neighborhood.destroy_all
  User.destroy_all
end

# Criar usuário administrador
puts "👤 Criando usuário administrador..."
admin = User.find_or_create_by(email: 'bercht@live.com') do |user|
  user.password = '12345678'
  user.password_confirmation = '12345678'
end

puts "✅ Usuário criado: #{admin.email}"

# Criar bairros
puts "🏘️ Criando bairros..."
neighborhoods = [
  'Centro',
  'Copacabana',
  'Ipanema',
  'Leblon',
  'Botafogo',
  'Flamengo',
  'Tijuca',
  'Barra da Tijuca'
]

neighborhoods.each do |name|
  Neighborhood.find_or_create_by(name: name)
end

puts "✅ #{Neighborhood.count} bairros criados"

# Criar propriedades de exemplo
puts "🏠 Criando propriedades de exemplo..."


descriptions = [
  'Imóvel com excelente localização, próximo ao comércio e transporte público. Acabamento de primeira qualidade.',
  'Propriedade ampla e bem iluminada, com vista panorâmica. Ideal para famílias.',
  'Imóvel moderno com design contemporâneo. Pronto para morar.',
  'Excelente oportunidade de investimento. Região em valorização.',
  'Propriedade única com características especiais. Não perca esta chance!'
]

20.times do |i|
  neighborhood = Neighborhood.all.sample
  
  property = Property.create!(
    title: "#{"Casa em"} #{i + 1} - #{neighborhood.name}",
    price: rand(300_000..2_000_000),
    description: descriptions.sample,
    neighborhood: neighborhood,
    featured: 0,
    bedrooms: rand(1..5),
    bathrooms: rand(1..4),
    area_m2: rand(50..300),
    garage_spaces: rand(0..3),
    property_type: "casa",
    furnished: [true, false].sample,
    created_at: rand(30.days.ago..Time.current)
  )
  
  puts "✅ Propriedade criada: #{property.title}"
end

puts "🎉 Seeds executados com sucesso!"
puts "📊 Estatísticas:"
puts "   - Usuários: #{User.count}"
puts "   - Bairros: #{Neighborhood.count}"
puts "   - Imóveis: #{Property.count}"
puts "   - Imóveis em destaque: #{Property.where(featured: true).count}"
puts ""
puts "🔑 Login do admin:"
puts "   Email: admin@clauss.com"
puts "   Senha: password123"
puts ""
puts "🌐 Acesse: http://localhost:3000/admin"






