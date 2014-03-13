module Spree
  # Gateway for Transbank Webpay Hosted Payment Pages solution
  class Gateway::Webpay < Gateway
    preference :api_environment,    :string, default: 'sandbox'
    preference :api_key,            :string
    preference :api_secret,        :string
    preference :api_payment_method, :string

    STATE = 'puntopagos'

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      Webpay::Api
    end

    def provider
      ::Webpay::Config.env      = has_preference?(:api_environment) ? preferred_api_environment : 'sandbox'
      ::Webpay::Config.key      = has_preference?(:api_key)         ? preferred_api_key         : nil
      ::Webpay::Config.secret   = has_preference?(:api_secret)      ? preferred_api_sercret     : nil

      provider_class
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
        if payment.webpay_params["respuesta"] == "00"
          ActiveMerchant::Billing::Response.new(true,  make_success_message(payment.webpay_params), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, make_failure_message(payment.webpay_params), {}, {})
        end
      else
        status = provider.check_status(payment.token, order.id.to_s, order.puntopagos_amount)

        if status.valid?
          ActiveMerchant::Billing::Response.new(true,  "Webpay paid, checked using Webpay::Status class", {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, status.error, {}, {})
        end
      end
    end

    def auto_capture?
      false
    end

    def method_type
      "Webpay"
    end

    private
    def make_success_message webpay_params
      webpay_params[:medio_pago_descripcion]
    end

    def make_failure_message webpay_params
      webpay_params[:error]
    end
  end
end