class AddColumnProvinceIdToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :province_id, :integer
  end

  def self.down
    remove_column :cities, :province_id
  end
end
