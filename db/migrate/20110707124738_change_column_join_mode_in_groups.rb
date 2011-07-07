class ChangeColumnJoinModeInGroups < ActiveRecord::Migration
  def self.up
    change_column :groups, :join_mode, :integer
  end

  def self.down
    change_column :groups, :join_mode, :string
  end
end
