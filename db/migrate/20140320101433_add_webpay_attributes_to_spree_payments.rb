class AddWebpayAttributesToSpreePayments < ActiveRecord::Migration
  def up
    add_column :spree_payments, :webpay_params, :hstore unless column_exists? :spree_payments, :webpay_params
  end

  def down
    remove_column :spree_payments, :webpay_params
  end
end
