class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :name
      t.references :imageable, :polymorphic => true 
      t.timestamps
    end
    
    Album.reset_column_information
    Event.all.each do |e|
      e.albums.create(:name => I18n.t('album.default'))
    end
  end

  def self.down
    drop_table :albums
  end
end
