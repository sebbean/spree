class AddDeletedAtToSpreeLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :deleted_at, :datetime
  end
end
