class AlbumsController < ApplicationController
  def show
    @album = Album.find( params[ :id ] )
    @person = Person.find( params[ :person_id ] )
    if @album
      @pics = @album.album_pics( @person )
    end
    @albums = @person.my_albums
  end
end
