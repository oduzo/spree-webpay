require 'spec_helper'

describe Spree::Order do
  let(:order) { create(:order, total: 20990.4) }

  ##############
  # methods #
  ##############
  it "respond to webpay_amount" do
    expect(order.webpay_amount).to eq(2099000)
  end
end