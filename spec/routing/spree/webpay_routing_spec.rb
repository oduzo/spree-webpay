require "spec_helper"

describe Spree::WebpayController do
  routes { Spree::Core::Engine.routes }

  describe "routing" do
    # The notification URL
    it "routes to #confirmation" do
      post('/spree/webpay/confirmation').should route_to('spree/webpay#confirmation')
    end

    # The success URL
    it "routes to #success" do
      get('/spree/webpay/success').should route_to('spree/webpay#success')
    end

    # The failure URL
    it "routes to #error" do
      get('/spree/webpay/failure').should route_to('spree/webpay#failure')
    end
  end
end
