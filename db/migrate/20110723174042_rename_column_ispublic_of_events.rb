class RenameColumnIspublicOfEvents < ActiveRecord::Migration
  def self.up
    rename_column :events, :ispublic, :is_private
  end

  def self.down
    rename_column :events,  :is_private, :ispublice
  end
end
