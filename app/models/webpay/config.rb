require 'yaml'

module TBK
  module Webpay
    class Config
      attr_accessor :config_filepath, :tbk_webpay_cgi_base_url, :tbk_webpay_tbk_root_path, :tbk_webpay_protocol

      attr_accessor :store_code

      # @@store_code  = ''

      # def self.store_code= value
      #   @@store_code = value
      # end
      # def self.store_code
      #   @@store_code
      # end

      # Public: Loads the configuration file tbk-webpay.yml
      # If it's a rails application it will take the file from the config/ directory
      #
      # env - Environment.
      #
      # Returns a Config object.
      def initialize env = nil, config_override = nil
        if env
          # For non-rails apps
          @config_filepath = File.join(File.dirname(__FILE__), "..", "..", "config", "tbk-webpay.yml")
          load(env)
        else
          @config_filepath = File.join(Rails.root, "config", "tbk-webpay.yml")
          load(Rails.env)
        end
      end

      private

      # Private: Initialize variables based on tbk-webpay.yml
      #
      # rails_env - Environment.
      #
      # Returns nothing.
      def load(rails_env)
        config = YAML.load_file(@config_filepath)[rails_env]
        @tbk_webpay_cgi_base_url = config['cgi_base_url']
        @tbk_webpay_tbk_root_path = config['tbk_root_path']
        @tbk_webpay_protocol = config['protocol']
      end
    end
  end
end