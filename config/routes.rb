Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/webpay/confirmation', to: 'webpay#confirmation', as: :webpay_confirmation

  # The success URL
  post 'spree/webpay/success', to: 'webpay#success', as: :webpay_success

  # The failure URL
  post 'spree/webpay/failure', to: 'webpay#failure', as: :webpay_failure
end