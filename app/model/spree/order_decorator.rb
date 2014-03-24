module Spree
  Order.class_eval do
    # Se re-define cuales son pagos pendientes
    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # Se re-define el checkout flow
    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment,    if: ->(order) { order.payment_required?              }
      go_to_state :webpay,     if: ->(order) { order.has_webpay_payment_method? }
      go_to_state :confirm,    if: ->(order) { order.confirmation_required?         }
      go_to_state :complete
      remove_transition from: :delivery, to: :confirm
    end

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

    # Indica si la orden tiene asociado un pago por Webpay
    #
    # Return TrueClass||FalseClass instance
    def has_webpay_payment_method?
      payments.from_webpay.any?
    end

    # Devuelvela forma de pago asociada a la order, se extrae desde el ultimo payment
    #
    # Return Spree::PaymentMethod||NilClass instance
    def payment_method
      has_webpay_payment_method? ? payments.from_webpay.order(:id).last.payment_method : nil
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