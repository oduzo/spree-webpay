module Spree
  CheckoutController.class_eval do
    def edit
      @payment = @order.payments.order(:id).last
      @config  = Tbk::Webpay::Config.new
      protocol = @config.protocol

      webpay_state = Spree::Gateway::WebpayPlus.STATE

      if params[:state] == webpay_state && @order.state == webpay_state
        payment_method     = @order.webpay_payment_method
        trx_id             = @payment.webpay_trx_id
        amount             = @order.webpay_amount
        success_url        = webpay_success_url(:protocol => protocol)
        failure_url        = webpay_failure_url(:protocol => protocol)
        provider = payment_method.provider.new
        response = provider.pay(amount, @order.number, trx_id, success_url, failure_url)

        respond_to do |format|
          format.html { render text: response }
        end
      end
    end
  end
end
