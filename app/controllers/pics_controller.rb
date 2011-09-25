class PicsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def index
    @album = Album.find(params[:album_id])
  end

  def paginate_pics
    @album = Album.find(params[:album_id])
    @pics = @album.pics.paginate :page => params[:page], 
                                 :per_page => 12 
    render :layout => false
  end

  def destroy
    photo = Pic.where(:id => params[:id]).first

    if photo
      photo.destroy
      render :nothing => true
    end
  end

  def batch_destroy
    pids = params[:pids].split(',')

    @person = current_user.person
    Pic.destroy_all(:id => pids, :author_id => @person.id)
    if params[ :event_id ]
      @event = Event.find(params[:event_id])
      redirect_to event_path(@event)
    else
      redirect_to home_path
    end
  end

  def create
    begin
      if params[:authenticity_token] #upload with iframe
        params[:photo][:user_file] =  params[ :qqfile ] 
      else
        params[:photo][:user_file] = file_handler(params)
      end
      @photo = Pic.initialize(params[:photo], self.request.host, self.request.port,current_user.person)
      @photo.pic_type = params[ :pic_type ]
      if @photo.save
        @photo.update_albums(current_user.person,params)
        @photo.process

        respond_to do |format|
          if params[:authenticity_token] #upload with iframe
            format.html{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
          else
            format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
          end
        end
      else
        respond_with @photo, :location => pics_path, :error => message
      end
    end
  end

  def update_description
    @event = Event.find(params[:id])
    pics = Pic.where(:id => [*params[:photos]])
    content ="%{event;#{@event.id}}"
    @status_message =StatusMessage.initialize(current_user,content)
    if pics && pics.size > 0
      pics.each do |pic|
       pic.update_attributes(:description => params[:desc][pic.id.to_s])
      end 
      @status_message.pics << pics
    end

    if @status_message.save
      @status_message.dispatch_post 
    end
    redirect_to album_pics_path(@event.albums.first)
  end
  
  private

  def file_handler(params)
      ######################## dealing with local files #############
      # get file name
      file_name =  params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create tempora##l file
      begin
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print request.raw_post.force_encoding('BINARY')
      rescue RuntimeError => e
        raise e unless e.message.include?('cannot generate tempfile')
        file = Tempfile.new(file_name) # Ruby 1.8 compatibility
        file.binmode
        file.print request.raw_post
      end
      # put data into this file from raw post request

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      file
  end  
end
