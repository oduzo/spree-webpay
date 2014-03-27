module Spree
  class WebpayController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data, :except => [:failure]

    # before_filter :ensure_order_not_completed

    # POST spree/webpay/confirmation
    def confirmation
      @payment.update_attributes webpay_params: params.to_hash
      provider = @payment_method.provider.new
      response = provider.confirmation params

      render text: response
      return
      
      render nothing: true
    end

    # GET spree/webpay/success
    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil

      if @payment.failed?
        # reviso si el pago esta fallido y lo envio a la vista correcta
        RestClient.post webpay_failure_path, params
        return
      else
        # Order to next state
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to checkout_state_path(@order.state) and return
        end

        if @order.completed?
          flash.notice = Spree.t(:order_processed_successfully)
          redirect_to completion_route and return
        else
          redirect_to checkout_state_path(@order.state) and return
        end
          
      end
    end

    # GET spree/webpay/failure
    def failure
      @order = Spree::Order.find_by_number(params[:TBK_ORDEN_COMPRA])
      @payment = Spree::Payment.find_by_trx_id(params[:TBK_ID_SESION])

      unless @order.completed?
        # To restore the Cart
        session[:order_id] = @order.id
        @current_order     = @order
      end

      unless ['processing', 'failed'].include?(@payment.state)
        @payment.started_processing!
        @payment.failure!
      end

      # reviso si el pago esta completo y lo envio a la vista correcta
      # RestClient.post webpay_success_path, :TBK_ID_SESION => params[:TBK_ID_SESION] and return if ['processing', 'completed'].include?(@payment.state)
    end

    private
      # Carga los datos necesarios
      def load_data
        @payment = Spree::Payment.find_by_trx_id(params[:TBK_ID_SESION])

        # Verifico que se encontro el payment
        RestClient.post webpay_failure_path, params and return unless @payment
        @payment_method = @payment.payment_method
        @order          = @payment.order
      end

      # Same as CheckoutController#ensure_order_not_completed
      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end

      # Same as CheckoutController#completion_route
      def completion_route
        spree.order_path(@order)
      end
  end
end
