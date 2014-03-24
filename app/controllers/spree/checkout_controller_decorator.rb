module Spree
  CheckoutController.class_eval do
    def edit
      @payment = @order.payments.order(:id).last

      if params[:state] == Spree::Gateway::WebpayPlus.STATE and @order.state == Spree::Gateway::WebpayPlus.STATE
        payment_method     = @order.payment_method

        trx_id             = @payment.trx_id.to_s
        api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
        amount             = @order.webpay_amount
        success_url        = webpay_success_url(:protocol => "http")
        failure_url        = webpay_failure_url(:protocol => "http")
        provider = payment_method.provider.new
        response = provider.pay(amount, @order.number, trx_id, success_url, failure_url)
        
        respond_to do |format|
          format.html { render text: response }
        end
        
      end
    end
  end
end
