Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/webpay/confirmation', to: 'webpay#confirmation', as: :webpay_confirmation

  # The result URL
  post 'spree/webpay/result', to: 'webpay#result'
  get 'spree/webpay/result', to: 'webpay#result', as: :webpay_result

  # The success URL
  post 'spree/webpay/success', to: 'webpay#success'
  get 'spree/webpay/success', to: 'webpay#success', as: :webpay_success

  # The failure URL
  post 'spree/webpay/failure', to: 'webpay#failure'
  get 'spree/webpay/failure', to: 'webpay#failure', as: :webpay_failure
end