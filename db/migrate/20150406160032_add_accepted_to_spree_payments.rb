class AddAcceptedToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :accepted, :boolean unless column_exists? :spree_payments, :accepted
  end
end