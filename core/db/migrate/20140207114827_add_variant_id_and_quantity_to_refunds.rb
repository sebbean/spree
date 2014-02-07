class AddVariantIdAndQuantityToRefunds < ActiveRecord::Migration
  def change
    add_column :spree_refunds, :variant_id, :integer
    add_column :spree_refunds, :quantity, :integer
  end
end
