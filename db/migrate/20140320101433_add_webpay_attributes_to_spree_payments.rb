class AddWebpayAttributesToSpreePayments < ActiveRecord::Migration
  if ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'postgresql'
    def up
      add_column :spree_payments, :webpay_params, :hstore
    end

    def down
      remove_column :spree_payments, :webpay_params
    end
  else
    def up
      add_column :spree_payments, :webpay_params, :string
    end

    def down
      remove_column :spree_payments, :webpay_params
    end
  end
end
