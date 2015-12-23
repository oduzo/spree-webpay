module Spree
  Payment.class_eval do
    scope :from_webpay, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::WebpayPlus.to_s}) }
    serialize(:webpay_params, Hash)

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
        return "Cuotas Normales"
      when "SI"
        return "Sin Interés"
      when "S2"
        return "Dos Cuotas Sin Interés"
      when "CI"
        return "Cuotas Comercio"
      when "NC"
        return "Cuotas sin interés"
      when "VD"
        return "Débito"
      else
        return webpay_params["TBK_TIPO_PAGO"]
      end
    end

    def webpay_payment_type
      if webpay_params["TBK_TIPO_PAGO"] == 'VD'
        return "Redcompra"
      else
        return "Crédito"
      end
    end

    private
      # Private: Setea un trx_id unico.
      #
      # Returns Token.
      def set_webpay_trx_id
        self.webpay_trx_id ||= generate_webpay_trx_id
      end

      # Private: Genera el trx_id unico.
      #
      # Returns generated trx_id.
      def generate_webpay_trx_id
        Digest::MD5.hexdigest("#{order.number}#{order.payments.count}") if order
      end
  end
end
