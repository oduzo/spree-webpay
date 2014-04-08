class AddWebpayIdToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :webpay_trx_id, :integer
  end
end
