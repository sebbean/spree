class DropStateChanges < ActiveRecord::Migration
  def change
    drop_table :spree_state_changes
  end
end
