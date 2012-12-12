class ChangeColumnContactIdAtPostVisibilities < ActiveRecord::Migration
  def self.up
    rename_column :post_visibilities, :contact_id, :person_id
  end

  def self.down
    rename_column :post_visibilities, :person_id,:contact_id
  end
end
