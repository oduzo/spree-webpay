module Spree
  CheckoutController.class_eval do
    def edit
      @payment = @order.payments.order(:id).last

      redirect_to webpay_success_path(@payment.token) and return if @payment and @payment.token? and ['processing', 'completed'].include?(@payment.state)

      redirect_to webpay_error_path(@payment.token) and return if @payment and @payment.token? and @payment.failed? and params[:state] != 'payment'

      if params[:state] == Spree::Gateway::WebpayPlus.STATE and @order.state == Spree::Gateway::WebpayPlus.STATE
        payment_method     = @order.payment_method

        trx_id             = @payment.trx_id.to_s
        api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
        amount             = @order.webpay_amount
        success_url        = webpay_success_url
        failure_url        = webpay_failure_url
        provider = payment_method.provider.new
        response = provider.pay(amount, @order.number, trx_id, success_url, failure_url)
        respond_to do |format|
          format.html { render text: response }
        end
        # if response.success?
        #   # TODO - ver si se puede reutilizar el token cuando este ya esta seteado
        #   @payment.update_attributes token: response.get_token
        #   redirect_to response.payment_process_url

        #   # To clean the Cart
        #   session[:order_id] = nil
        #   @current_order     = nil

        #   return
        # else
        #   @error = response.get_error
        # end
      end
    end
  end
end
