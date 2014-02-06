class DropReturnAuthorizationsTable < ActiveRecord::Migration
  def change
    drop_table :spree_return_authorizations
  end
end
