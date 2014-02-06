class CreateSpreeRefundItems < ActiveRecord::Migration
  def change
    create_table :spree_refund_items do |t|
      t.integer :refund_id
      t.integer :variant_id
      t.string :state
      t.decimal :price, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
