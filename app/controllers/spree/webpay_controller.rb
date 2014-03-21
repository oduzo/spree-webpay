module Spree
  class WebpayController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data

    before_filter :ensure_order_not_completed

    # POST spree/webpay/confirmation
    def confirmation
      provider = @payment_method.provider.new
      response = provider.confirmation params

      @payment.update_attributes webpay_params: params.to_hash

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
        redirect_to webpay_error_path(@payment.token)
        return
      else
        # Consulto la API de Puntopagos para ver el estado de la transaccion
        # status = @payment.payment_method.provider.new.check_status(@payment.token, @payment.trx_id.to_s, @order.amount)
        status = true
        if status.valid?
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
        else
          redirect_to webpay_failure_path and return
        end
      end
    end

    # GET spree/webpay/failure
    def failure
      # TODO - quiza aca se puede pasar el pago a :failure

      unless @order.completed?
        # To restore the Cart
        session[:order_id] = @order.id
        @current_order     = @order
      end

      # reviso si el pago esta completo y lo envio a la vista correcta
      redirect_to webpay_success_path and return if ['processing', 'completed'].include?(@payment.state)
    end

    private
      # Carga los datos necesarios
      def load_data
        Rails.logger.info params
        @payment = Spree::Payment.find_by_trx_id(params[:TBK_ID_SESION])

        # Verifico que se encontro el payment
        redirect_to spree.cart_path and return unless @payment

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
