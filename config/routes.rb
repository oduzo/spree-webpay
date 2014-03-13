Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/webpay/:token/confirmation', to: 'webpay#confirmation', as: :webpay_confirmation

  # The success URL
  get 'spree/webpay/:token/success', to: 'webpay#success', as: :webpay_success

  # The failure URL
  get 'spree/webpay/:token/error', to: 'webpay#error', as: :webpay_error
end