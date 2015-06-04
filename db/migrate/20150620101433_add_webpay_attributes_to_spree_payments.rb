class AddWebpayAttributesToSpreePayments < ActiveRecord::Migration
  def change
    if column_exists?(:spree_payments, :webpay_params)
      change_column(:spree_payments, :webpay_params, :text)
    else
      add_column :spree_payments, :webpay_params, :text
    end
  end
end
