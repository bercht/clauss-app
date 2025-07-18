# config/environments/production.rb
Rails.application.configure do
  # CRÍTICO: Servir assets estáticos no Heroku
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  
  # Configuração de cache para assets
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000'
  }
  
  # Configuração de assets
  config.assets.compile = false  # NUNCA true em produção
  config.assets.digest = true
  config.assets.precompile += %w(*.js *.css)
  
  # Configuração para Rails 7 + Stimulus
  config.importmap.sweep_cache = true

  # Configuração do ActiveStorage
  config.active_storage.service = :amazon
  config.active_storage.variant_processor = :mini_magick
  config.active_storage.resolve_model_to_route = :rails_storage_proxy
  
  # Configuração de logs
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
  
  # Configurações de produção
  config.action_mailer.default_url_options = { host: 'https://clauss-app-170118de184f.herokuapp.com/' }
  config.action_controller.default_url_options = { host: 'https://clauss-app-170118de184f.herokuapp.com/' }
  config.active_storage.service = :amazon
  config.active_storage.variant_processor = :mini_magick
  config.force_ssl = true
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
end
