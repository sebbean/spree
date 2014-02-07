class AddCurrencyToRefundItems < ActiveRecord::Migration
  def change
    add_column :spree_refund_items, :currency, :string
  end
end
