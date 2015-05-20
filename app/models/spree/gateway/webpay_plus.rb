# encoding: utf-8
module Spree
  # Gateway for Transbank Webpay Hosted Payment Pages solution
  class Gateway::WebpayPlus < Gateway
    preference :store_code, :string

    def self.STATE
      'webpay'
    end

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      TBK::Webpay::Payment
    end

    def provider
      provider_class.new preferred_store_code
    end

    def actions
      %w{capture}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def capture(money_cents, response_code, gateway_options)
      gateway_order_id   = gateway_options[:order_id]
      order_number       = gateway_order_id.split('-').first
      payment_identifier = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(identifier: payment_identifier)
      order   = payment.order

      if payment.webpay_params?
        if payment.webpay_params["TBK_COD_RESP_M001"] == "0"
          ActiveMerchant::Billing::Response.new(true,  make_success_message(payment.webpay_params), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, make_failure_message(payment.webpay_params), {}, {})
        end
      else
        ActiveMerchant::Billing::Response.new(false, "Transacción no aprobada #{payment.webpay_params}", {}, {})
      end
    end

    def auto_capture?
      false
    end

    def method_type
      "webpay"
    end

    def credit(money, credit_card, response_code, options = {})
      ActiveMerchant::Billing::Response.new(true, '#{Spree::Gateway::WebpayPlus.to_s}: Forced success', {}, {})
    end

    def void(response_code, options = {})
      ActiveMerchant::Billing::Response.new(true, '#{Spree::Gateway::WebpayPlus.to_s}: Forced success', {}, {})
    end

    #TODO: Make administrable
    def payment_method_logo
      "http://www.puntopagos.com/content/mp3.gif"
    end

    private
    def make_success_message webpay_params
      "#{webpay_params['TBK_ORDEN_COMPRA']} - Código Autorización: #{webpay_params['TBK_CODIGO_AUTORIZACION']}"
    end

    def make_failure_message webpay_params
      webpay_params["TBK_CODIGO_AUTORIZACION"]
    end
  end
end
