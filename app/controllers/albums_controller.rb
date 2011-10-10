class AlbumsController < ApplicationController
  def show
    @album = Album.find( params[ :id ] )
    @person = Person.find( params[ :person_id ] )
    if @album
      @pics = @album.album_pics( @person )
    end
    @albums = @person.my_albums
  end

  def update
    pics = Pic.where(:id => [*params[:photos]])
    @album = Album.find( params[ :id ] )
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @album.pics << pics
    end
    redirect_to :back
  end

  def create
    pics = Pic.where(:id => [*params[:photos]])
    @album = Album.new
    @album.imageable = current_user.person
    @album.name = params[:album][ :name ]
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @album.pics << pics
    end
    @album.save
    redirect_to :back
  end
end
