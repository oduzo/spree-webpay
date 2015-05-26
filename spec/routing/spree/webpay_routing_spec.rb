require "spec_helper"

describe Spree::WebpayController do
  routes { Spree::Core::Engine.routes }

  describe "routing" do
    # The notification URL
    it "routes to #confirmation [POST]" do
      post('/webpay/confirmation').should route_to('spree/webpay#confirmation')
    end

    # The success URL
    it "routes to #success [GET]" do
      get('/webpay/success').should route_to('spree/webpay#success')
    end

    it "routes to #success [POST]" do
      post('/webpay/success').should route_to('spree/webpay#success')
    end

    # The failure URL
    it "routes to #error [GET]" do
      get('/webpay/failure').should route_to('spree/webpay#failure')
    end

    it "routes to #error [POST]" do
      post('/webpay/failure').should route_to('spree/webpay#failure')
    end
  end
end
