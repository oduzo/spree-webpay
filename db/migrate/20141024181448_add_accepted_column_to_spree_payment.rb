class AddAcceptedColumnToSpreePayment < ActiveRecord::Migration
  def change
    add_column :spree_payments, :accepted, :boolean

    unless index_exists?(:spree_payments, :webpay_trx_id)
      add_index :spree_payments, :webpay_trx_id
    end
  end
end
