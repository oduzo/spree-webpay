class AddAcceptedToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :accepted, :boolean
  end
end