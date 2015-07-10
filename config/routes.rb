Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'webpay/confirmation', to: 'webpay#confirmation', as: :webpay_confirmation

  # The success URL
  match 'webpay/success', to: 'webpay#success', as: :webpay_success, via: [:get, :post]

  # The failure URL
  match 'webpay/failure', to: 'webpay#failure', as: :webpay_failure, via: [:get, :post]

  get 'webpay/maker', to: 'webpay#maker', as: :webpay_maker
end
