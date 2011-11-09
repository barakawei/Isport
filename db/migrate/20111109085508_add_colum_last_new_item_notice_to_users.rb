class AddColumLastNewItemNoticeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_new_item_notice_at, :timestamp

    User.all.each do |u|
      last_sign_in = u.last_sign_in_at
      u.update_attribute(:last_new_item_notice_at, last_sign_in) 
    end
  end

  def self.down
    remove_column :users, :last_new_item_notice_at
  end
end
