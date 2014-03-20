class AddTrxWebpayToSpreePayments < ActiveRecord::Migration
  def change
    unless column_exists?(:spree_payments, :trx_id)
      add_column :spree_payments, :trx_id, :integer
    end
  end
end
