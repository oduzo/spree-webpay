module Spree
  class WebpayController < StoreController
    skip_before_filter :verify_authenticity_token

    before_filter :load_data, :except => [:failure]

    # GET spree/webpay/maker
    def maker
      redirect_to spree.root_path if Rails.env.production?

      @webpay = {}
      @webpay[:TBK_TIPO_TRANSACCION] = "TR_NORMAL"
      if current_order
        @webpay[:TBK_ORDEN_COMPRA]     = current_order.number
        @webpay[:TBK_ID_SESION]        = current_order.payments.valid.last.try(:webpay_trx_id) || current_order.dummy_webpay_trx_id
        @webpay[:TBK_MONTO]            = current_order.webpay_amount
      end
      @webpay[:TBK_URL_CONFIRMACION] = spree.webpay_confirmation_url
      @webpay[:TBK_URL_EXITO]        = spree.webpay_success_url
      @webpay[:TBK_URL_FRACASO]      = spree.webpay_failure_url

      render :layout => false
    rescue => error
      flash[:error] = error.message.to_s
      redirect_to spree.root_path
    end

    # POST spree/webpay/confirmation
    def confirmation
      if @payment.blank?
        render text: "RECHAZADO"
        return
      end

      @payment.update_attributes webpay_params: params.to_hash
      provider = @payment_method.provider.new
      response = provider.confirmation params

      render text: response
      return

      render nothing: true
    end

    # GET/POST spree/webpay/success
    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil

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
  end
end
