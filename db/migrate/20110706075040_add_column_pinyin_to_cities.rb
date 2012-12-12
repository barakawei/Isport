class AddColumnPinyinToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :pinyin, :string
  end

  def self.down
    remove_column :cities, :pinyin
  end
end
