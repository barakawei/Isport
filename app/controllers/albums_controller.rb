class AlbumsController < ApplicationController
  respond_to :js
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
    @person = current_user.person
    @album = Album.find( params[ :id ] )
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @album.pics << pics
    end
    respond_with [@person,@album]
  end

  def create
    pics = Pic.where(:id => [*params[:photos]])
    @album = Album.new
    @person =  current_user.person
    @album.imageable = @person
    @album.name = params[:album][ :name ]
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @album.pics << pics
    end
    @album.save
    respond_with @person
  end

  def destroy
    album = Album.find( params[ :id ] )
    album.destroy
    person =  current_user.person
    redirect_to person_album_path( person,person.albums.default_album("status_message").first )
  end
end
