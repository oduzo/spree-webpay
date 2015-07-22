module SpreeTbkWebpay
  module Generators
    class InstallGenerator < Rails::Generators::Base

      class_option :auto_run_migrations, :type => :boolean, :default => false

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_tbk_webpay'
      end

      def config_yml
        create_file "config/tbk-webpay.yml" do
          settings = {
            'development' => {
              'protocol' => 'http',
              'cgi_base_url' => 'http://example.com/cgi-bin',
              'tbk_root_path' => '/home/deploy/cgi-bin-tbk'
            },
            'test' => {
              'protocol' => 'http',
              'cgi_base_url' => 'http://example.com/cgi-bin',
              'tbk_root_path' => '/home/deploy/cgi-bin-tbk'
            }
          }
          settings.to_yaml
        end
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
