module Spree
  Payment.class_eval do
    scope :from_webpay, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::WebpayPlus.to_s}) }

    after_initialize :set_webpay_trx_id

    def webpay?
      self.payment_method.type == "Spree::Gateway::WebpayPlus"
    end

    def webpay_card_number
      "XXXX XXXX XXXX #{webpay_params['TBK_FINAL_NUMERO_TARJETA']}"
    end

    def webpay_quota_type
      case webpay_params["TBK_TIPO_PAGO"]
      when "VN"
        return "Sin Cuotas"
      when "VC"
        return "Normales"
      when "SI"
        return "Sin Intereses"
      when "CI"
        return "Cuotas Comercio"
      when "VD"
        return "Sin Cuotas"
      else
        return webpay_params["TBK_TIPO_PAGO"]
      end
    end

    def webpay_payment_type
      case webpay_params["TBK_TIPO_PAGO"]
      when "VN"
        return "Venta Normal"
      when "VC"
        return "Venta Cuotas"
      when "SI"
        return "Tres Cuotas Sin Interés"
      when "CI"
        return "Cuotas Comercio"
      when "VD"
        return "Redcompra"
      else
        return webpay_params["TBK_TIPO_PAGO"]
      end
    end

    private
      # Public: Setea un trx_id unico.
      #
      # Returns Token.
      def set_webpay_trx_id
        self.webpay_trx_id ||= generate_trx_id
      end

      # Public: Genera el trx_id unico.
      #
      # Returns generated trx_id.
      def generate_trx_id
        while true
          generated_webpay_trx_id = Digest::MD5.hexdigest("#{order.number}#{order.payments.count}")

          return generated_webpay_trx_id unless Spree::Payment.exists?(webpay_trx_id: generated_webpay_trx_id)
        end
      end
  end
end
