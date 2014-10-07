# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_tbk_webpay'
  s.version     = '1.2.3'
  s.summary     = 'Plugs Webpay Payment Gateway into Spree Stores'
  s.description = 'Plugs Webpay Payment Gateway into Spree Stores'
  s.required_ruby_version = '>= 1.9.3'

  s.authors     = ["Gonzalo Bulnes, Ignacio Mella, Cristian Carreño, Ignacio Verdejo, Gonzalo Moreno, Alfonso Cabargas"]
  s.email       = ["iverdejo@acid.cl, gmoreno@acid.cl, fcabargas@acid.cl"]
  s.homepage    = 'http://www.acid.cl'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.3.0'
  s.add_dependency 'spree_frontend', '~> 2.3.0'
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails',  '~> 4.0.3'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'

  s.add_runtime_dependency 'rest-client', '~> 1.6.7'
end
