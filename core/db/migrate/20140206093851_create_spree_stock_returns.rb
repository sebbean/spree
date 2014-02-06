class CreateSpreeStockReturns < ActiveRecord::Migration
  def change
    create_table :spree_stock_returns do |t|

      t.timestamps
      t.references :order
    end
  end
end
