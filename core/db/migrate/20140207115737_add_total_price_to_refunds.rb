class AddTotalPriceToRefunds < ActiveRecord::Migration
  def change
    add_column :spree_refunds, :total_price, :decimal, precision: 8, scale: 2
  end
end
