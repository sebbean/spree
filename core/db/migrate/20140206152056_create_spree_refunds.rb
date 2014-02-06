class CreateSpreeRefunds < ActiveRecord::Migration
  def change
    create_table :spree_refunds do |t|
      t.integer :stock_return_id

      t.timestamps
    end
  end
end
