FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_tbk_webpay/factories'
  factory :webpay_payment_method, class: Spree::Gateway::WebpayPlus do
    name 'Webpay'
  end

  factory :payment_with_params, class: Spree::Payment do 
    order
    webpay_params({"TBK_VCI"=>"TSY", "TBK_MONTO"=>"13599200", "TBK_ID_SESION"=>"fd5557da22c2fe86f4d920a93259f261", "TBK_RESPUESTA"=>"0", "TBK_TIPO_PAGO"=>"VD", "TBK_ORDEN_COMPRA"=>"R786645788", "TBK_NUMERO_CUOTAS"=>"0", "TBK_FECHA_CONTABLE"=>"0525", "TBK_ID_TRANSACCION"=>"259432742", "TBK_HORA_TRANSACCION"=>"195153", "TBK_TIPO_TRANSACCION"=>"TR_NORMAL", "TBK_FECHA_TRANSACCION"=>"0525", "TBK_CODIGO_AUTORIZACION"=>"006634", "TBK_FINAL_NUMERO_TARJETA"=>"6543"})
  end
end
