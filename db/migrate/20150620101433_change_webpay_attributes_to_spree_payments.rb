class ChangeWebpayAttributesToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :webpay_params, :text
  end
end
