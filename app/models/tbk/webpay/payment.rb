require 'rest_client'
require 'multi_logger'

module Tbk
  module Webpay
    class Payment
      # Public: Loads the configuration file tbk-webpay.yml
      # If it's a rails application it will take the file from the config/ directory
      #
      # env - Environment.
      #
      # Returns a Config object.
      def initialize env = nil
        @config ||= Tbk::Webpay::Config.new(env)
      end

      # Public: Initial communication from the application to Webpay servers
      #
      # tbk_total_price - integer - Total amount of the purchase. Last two digits are considered decimals.
      # tbk_order_id - integer - The purchase order id.
      # session_id - integer - The user session id.
      #
      # Returns a REST response to be rendered by the application
      def pay tbk_total_price, order_id, session_id, success_url, failure_url
        tbk_params = {
          'TBK_TIPO_TRANSACCION' => 'TR_NORMAL',
          'TBK_MONTO' => tbk_total_price,
          'TBK_ORDEN_COMPRA' => order_id,
          'TBK_ID_SESION' => session_id,
          'TBK_URL_FRACASO' => failure_url,
          'TBK_URL_EXITO' => success_url
        }

        cgi_url = "#{@config.tbk_webpay_cgi_base_url}/tbk_bp_pago.cgi"

        tbk_string_params = ""

        tbk_params.each do |key, value|
          tbk_string_params += "#{key}=#{value}&"
        end

        Rails.logger.info '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
        Rails.logger.info cgi_url
        Rails.logger.info tbk_string_params
        Rails.logger.info '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'

        result = RestClient.post cgi_url, tbk_string_params
      end

      # Public: Confirmation callback executed from Webpay servers.
      # Checks Webpay transactions workflow.
      #
      # Returns a string redered as text.
      def confirmation params
        @logfile = "#{Time.now.to_date.to_s.underscore}_webpay"
        @payment = Spree::Payment.find_by(webpay_trx_id: params[:TBK_ID_SESION])
        @payment.reload
        @verbose = @payment.payment_method.preferred_verbose
        file_path = "#{@config.tbk_webpay_tbk_root_path}/log/MAC01Normal#{params[:TBK_ID_SESION]}.txt"
        tbk_mac_path = "#{@config.tbk_webpay_tbk_root_path}/tbk_check_mac.cgi"
        @mac_string = ""
        params.except(:controller, :action, :current_store_id).each do |key, value|
          @mac_string += "#{key}=#{value}&" if key != :controller or key != :action or key != :current_store_id
        end
        @order = Spree::Order.find_by number: params[:TBK_ORDEN_COMPRA]
        @order.reload

        begin
          MultiLogger.add_logger("#{@logfile}") if @verbose
        rescue
          # Nothing for now
        end

        if params[:TBK_RESPUESTA] == "0"

          logger("Inicio", "") if @verbose

          @mac_string.chop!
          unless Rails.env.development?
            File.open file_path, 'w+' do |file|
              file.write(@mac_string)
            end
          end

          logger("Check Mac", @mac_string) if @verbose
          unless Rails.env.development?
            check_mac = system(tbk_mac_path.to_s, file_path.to_s)
          else
            check_mac = true
          end

          accepted = true
          unless check_mac
            accepted = false
            logger("Failed check mac", "") if @verbose
          end

          # the confirmation is invalid if order_id is unknown
          if not order_exists?
            accepted = false
          end

          # double payment
          if order_paid?
            accepted = false
          end

          # wrong amount
          if not order_right_amount? params[:TBK_MONTO]
            accepted = false
          end

          if accepted && !['failed', 'invalid'].include?(@payment.state)
            logger("Valid", ":)") if @verbose
            @payment.update_column(:accepted, true)

            if @payment.payment_method.preferred_use_async
              WebpayJob.perform_later(@payment.id, "accepted")
            else
              @payment.capture!
              @payment.order.next!
            end

            logger("Completed", ":)") if @verbose
            return "ACEPTADO"
          else
            logger("Invalid", ":(") if @verbose
            unless ['completed', 'failed', 'invalid'].include?(@payment.state)
              @payment.update_column(:accepted, false)

              if @payment.payment_method.preferred_use_async
                WebpayJob.perform_later(@payment.id, "rejected")
              else
                @payment.started_processing!
                @payment.failure!
              end

            end
            logger("Rejected", ":(") if @verbose
            return "RECHAZADO"
          end

        else  # TBK_RESPUESTA != 0
          logger("TBK_RESPUESTA != 0", params[:TBK_RESPUESTA]) if @verbose
          return "ACEPTADO"
        end

      end

      private

      # Private: Checks if an order exists and is ready for payment.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order exists and is ready for payment.
      def order_exists?
        result = @order.is_a? Spree::Order
        logger(__method__.to_s, result) if @verbose
        return result
      end

      # Private: Checks if an order is already paid.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order is already paid.
      def order_paid?
        return false unless @order
        result = @order.paid? || @order.payments.completed.any?
        logger(__method__.to_s, result) if @verbose
        return result
      end

      # Private: Checks if an order has the same amount given by Webpay.
      #
      # order_id - integer - The purchase order id.
      # tbk_total_amount - The total amount of the purchase order given by Webpay.
      #
      # Returns a boolean indicating if the order has the same total amount given by Webpay.
      def order_right_amount? tbk_total_amount
        return false unless @order
        result = @order.webpay_amount.to_i == tbk_total_amount.to_i
        logger(__method__.to_s, result) if @verbose
        return result
      end

      def logger message, value
        Rails.logger.send("#{@logfile}").info("[#{@order.number} #{@order.try(:state)}] #{message} #{value}")
      end
    end
  end
end