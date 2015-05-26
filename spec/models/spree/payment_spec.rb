require 'spec_helper'

describe Spree::Payment do
  let(:order) { Spree::Order.create }
  let(:payment) {order.payments.build}

  ##############
  # attributes #
  ##############
  it "has a webpay_params" do
    should respond_to :webpay_params
  end

  it "has a webpay_trx_id" do
    should respond_to :webpay_trx_id
  end

  ##############
  # methods #
  ##############
  it "has a uniq webpay_trx_id" do
    hash = Digest::MD5.hexdigest("#{order.number}#{order.payments.count}")
    expect(payment.webpay_trx_id).to eq(hash)
  end

  it "has serializated webpay_params" do
    payment = FactoryGirl.create :payment_with_params
    expect(payment.webpay_params["TBK_TIPO_TRANSACCION"]).to eq("TR_NORMAL")
  end

end