module Spree
  CheckoutController.class_eval do
    def edit
      @payment = @order.payments.order(:id).last


      if params[:state] == Spree::Gateway::WebpayPlus.STATE and @order.state == Spree::Gateway::WebpayPlus.STATE
        payment_method     = @order.webpay_payment_method
        provider           = payment_method.provider

        amount             = @order.webpay_amount
        trx_id             = @payment.webpay_trx_id
        result_url         = webpay_result_url(protocol: provider.config.tbk_webpay_protocol)
        failure_url        = webpay_failure_url(protocol: provider.config.tbk_webpay_protocol)

        response = provider.pay(amount, @order.number, trx_id, result_url, failure_url, @payment.id)

        respond_to do |format|
          format.html { render text: response }
        end
      end
    end
  end
end
