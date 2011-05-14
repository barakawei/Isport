class PhotosController < ApplicationController
  respond_to :html, :json

  
  def create
    begin
      params[:photo][:file] = file_handler(params)

      @photo = Photo.initialize( params[ :photo ] )

      if @photo.save
        @photo.process

        if params[:photo][:set_profile_photo]
          profile_params = {:image_url => @photo.url(:thumb_large),
                           :image_url_medium => @photo.url(:thumb_medium),
                           :image_url_small => @photo.url(:thumb_small)}
          puts params[ :photo ]
          update_profile(profile_params)
        end

        respond_to do |format|
          format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        end
      else
        respond_with @photo, :location => photos_path, :error => message
      end
      
    end
   
  end

  private

  def file_handler(params)
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
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
