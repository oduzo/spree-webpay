module Spree
  Order.class_eval do
    # Se re-define cuales son pagos pendientes
    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # Step only visible when payment failure
    
    insert_checkout_step :webpay, :after => :payment, if: Proc.new {|order| order.has_webpay_payment_method? or order.state == Spree::Gateway::WebpayPlus.STATE}
    remove_transition from: :payment, to: :complete,  if: Proc.new {|order| order.has_webpay_payment_method? or order.state == Spree::Gateway::WebpayPlus.STATE}
    
    
    # Indica si la orden tiene algun pago con Webpay completado con exito
    #
    # Return TrueClass||FalseClass instance
    def webpay_payment_completed?
      if payments.completed.from_webpay.any?
        true
      else
        false
      end
    end

    def webpay_client_name
      if ship_address
        ship_address.full_name
      else
        "#{user.firstname} #{user.lastname}"
      end
    end


    # Indica si la orden tiene asociado un pago por Webpay
    #
    # Return TrueClass||FalseClass instance
    def has_webpay_payment_method?
      payments.valid.from_webpay.any?
    end

    # Devuelvela forma de pago asociada a la order, se extrae desde el ultimo payment
    #
    # Return Spree::PaymentMethod||NilClass instance
    def webpay_payment_method
      has_webpay_payment_method? ? payments.valid.from_webpay.order(:id).last.payment_method : nil
    end

    # Entrega en valor total en un formato compatible con el estandar de Webpay
    #
    # Return String instance
    def webpay_amount
      # TODO - Ver que pasa cuando hay decimales
      "#{total.to_i}00"
    end
  end
end