require 'rest_client'

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
        @@config ||= Tbk::Webpay::Config.new(env)
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

        cgi_url = "#{@@config.tbk_webpay_cgi_base_url}/tbk_bp_pago.cgi"

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
        logfile = "#{Time.now.to_date.to_s.underscore}_webpay"
        payment = Spree::Payment.find_by(webpay_trx_id: params[:TBK_ID_SESION])
        file_path = "#{@@config.tbk_webpay_tbk_root_path}/log/MAC01Normal#{params[:TBK_ID_SESION]}.txt"
        tbk_mac_path = "#{@@config.tbk_webpay_tbk_root_path}/tbk_check_mac.cgi"
        mac_string = ""
        params.except(:controller, :action, :current_store_id).each do |key, value|
          mac_string += "#{key}=#{value}&" if key != :controller or key != :action or key != :current_store_id
        end
        order = Spree::Order.find_by number: params[:TBK_ORDEN_COMPRA]

        begin
          MultiLogger.add_logger("#{logfile}")
        rescue
          # Nothing for now
        end

        if params[:TBK_RESPUESTA] == "0"

          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Inicio")

          mac_string.chop!
          File.open file_path, 'w+' do |file|
              file.write(mac_string)
          end

          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Check Mac: #{mac_string}")

          check_mac = system(tbk_mac_path.to_s, file_path.to_s)

          accepted = true
          unless check_mac
            accepted = false
            Rails.logger.send("#{logfile}").warn("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Failed check mac: #{mac_string}, #{file_path}, #{tbk_mac_path}")
          end

          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Check Order exists")
          # the confirmation is invalid if order_id is unknown
          if not order_exists? params[:TBK_ORDEN_COMPRA], params[:TBK_ID_SESION]
            accepted = false
            Rails.logger.send("#{logfile}").warn("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Fail Check Order")
          end

          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Check Order Paid?")
          # double payment
          if order_paid? params[:TBK_ORDEN_COMPRA]
            accepted = false
            Rails.logger.send("#{logfile}").warn("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Fail Check Order Paid?")
          end

          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Check Order Amount")
          # wrong amount
          if not order_right_amount? params[:TBK_ORDEN_COMPRA], params[:TBK_MONTO]
            accepted = false
            Rails.logger.send("#{logfile}").warn("[v#{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Fail Check Order Amount")
          end

          if accepted
            Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Valid ")
            unless ['failed', 'invalid'].include?(payment.state)
              payment.update_column(:accepted, true)
              WebpayWorker.perform_async(payment.id, "accepted")
            end
            Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Completed ")
            return "ACEPTADO"
          else
            Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Invalid ")
            unless ['completed', 'failed', 'invalid'].include?(payment.state)
              payment.update_column(:accepted, false)
              WebpayWorker.perform_async(payment.id, "rejected")
            end
            Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] Rejected ")
            return "RECHAZADO"
          end

        else  # TBK_RESPUESTA != 0
          Rails.logger.send("#{logfile}").info("[Original #{params[:TBK_ORDEN_COMPRA]} #{order.try(:state)}] TBK_RESPUESTA = #{params[:TBK_RESPUESTA]} ")
          return "ACEPTADO"
        end

      end

      private

      # Private: Checks if an order exists and is ready for payment.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order exists and is ready for payment.
      def order_exists?(order_id, session_id)
        order = Spree::Order.find_by_number(order_id)
        if order.blank?
          return false
        else
          return true
        end
      end

      # Private: Checks if an order is already paid.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order is already paid.
      def order_paid? order_id
        order = Spree::Order.find_by_number(order_id)
        return order.paid?
      end

      # Private: Checks if an order has the same amount given by Webpay.
      #
      # order_id - integer - The purchase order id.
      # tbk_total_amount - The total amount of the purchase order given by Webpay.
      #
      # Returns a boolean indicating if the order has the same total amount given by Webpay.
      def order_right_amount? order_id, tbk_total_amount
        order = Spree::Order.find_by_number(order_id)
        if order.blank?
          return false
        else
          return order.webpay_amount == tbk_total_amount
        end
      end
    end
  end
end