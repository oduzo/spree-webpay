module Spree
  class WebpayController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data, :except => [:failure]

    # POST spree/webpay/confirmation
    def confirmation
      if @payment.blank?
        render text: "RECHAZADO"
        return
      end

      @payment.update_attributes webpay_params: params.to_hash
      provider = @payment_method.provider
      response = provider.confirmation params

      render text: response
      return

      render nothing: true
    end

    # GET/POST spree/webpay/result
    def result
      # To clean the Cart
      # ensure_new_order

      redirect_to root_path and return if @payment.blank?

      if @payment.failed?
        # reviso si el pago esta fallido y lo envio a la vista correcta
        redirect_to webpay_failure_path(params) and return
      else
        if @order.completed?
          redirect_to completion_route and return
        else
          redirect_to webpay_failure_path(params) and return
        end
      end
    end

    # GET/POST spree/webpay/success
    def success
      # To clean the Cart
      # ensure_new_order

      redirect_to root_path and return if @payment.blank?

      if @payment.failed? || !@payment.accepted
        # reviso si el pago esta fallido y lo envio a la vista correcta
        redirect_to webpay_failure_path(params) and return
      else
        if @order.completed? || @payment.accepted
          flash.notice = Spree.t(:order_processed_successfully)
          redirect_to completion_route and return
        else
          redirect_to webpay_failure_path(params) and return
        end
      end
    end

    # GET spree/webpay/failure
    def failure
      @order = Spree::Order.find_by(number: params[:TBK_ORDEN_COMPRA])
    end

    private
      # Carga los datos necesarios
      def load_data
        @payment = Spree::Payment.find_by(webpay_trx_id: params[:TBK_ID_SESION])

        # Verifico que se encontro el payment
        # redirect_to webpay_failure_path(params) and return unless @payment
        unless @payment.blank?
          @payment_method = @payment.payment_method
          @order          = @payment.order
        end
      end

      # Same as CheckoutController#completion_route
      def completion_route
        spree.order_path(@order)
      end

      def ensure_new_order
        # Olvida la sesion, asi creara una nueva orden
        session[:order_id] = nil
        @current_order     = nil
        cookies.signed[:guest_token] = nil
        cookies.permanent.signed[:guest_token] = SecureRandom.urlsafe_base64(nil, false)
      end
  end
end
