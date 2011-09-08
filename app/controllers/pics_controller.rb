class PicsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def destroy
    photo = Pic.where(:id => params[:id]).first

    if photo
      photo.destroy
      render :nothing => true
    end
  end

  def batch_destroy
     pids = params[:pids].split(',')
     @event = Event.find(params[:event_id])
     @person = current_user.person
     Pic.destroy_all(:id => pids, :author_id => @person.id)
     redirect_to event_path(@event)
  end

  def create
    @event = Event.find(params[:id])
    begin
      if params[:authenticity_token] #upload with iframe
        params[:photo][:user_file] =  params[ :qqfile ] 
      else
        params[:photo][:user_file] = file_handler(params)
      end
      @photo = Pic.initialize(params[ :photo ], self.request.host, self.request.port,current_user.person)

      if @photo.save
        @event.albums.first.pics << @photo
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
    pids = params[:photos]
    if pids.size > 0
      pids.each do |id|
        Pic.find(id).update_attributes(:description => params[:content][id])
      end 
    end
    redirect_to events_path
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
