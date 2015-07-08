# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_tbk_webpay'
  s.version     = '3.0.3'
  s.summary     = 'Webpay Payment into Spree Stores'
  s.description = 'Plugs Webpay Payment Gateway into Spree Stores'
  s.required_ruby_version = '>= 2.0.0'
  s.license     = 'MIT'
  s.authors     = ["Gonzalo Bulnes, Ignacio Mella, Cristian Carreño, Ignacio Verdejo, Gonzalo Moreno"]
  s.email       = ["iverdejo@acid.cl, gmoreno@acid.cl"]
  s.homepage    = 'http://www.acid.cl'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.1'
  s.add_dependency 'spree_frontend', '~> 3.0.1'
  s.add_dependency 'sidekiq'
  s.add_dependency 'multi_logger'
  s.add_dependency 'rest-client'
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'

end
