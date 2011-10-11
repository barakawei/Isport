class PhotosController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :html, :json

  def destroy
    photo = Post.where(:id => params[:id]).first

    if photo
      photo.destroy
      respond_to do |format|
        format.json{ render :nothing => true, :status => 204 }
      end
    end
  end
  

  def create
    begin
      if params[:authenticity_token] #upload with iframe
        params[:photo][:user_file] =  params[ :qqfile ] 
      else
        params[:photo][:user_file] = file_handler(params)
      end
      @photo = Pic.initialize(params[ :photo ], self.request.host, self.request.port,current_user.person)
      @photo.pic_type = "avatar"
      if @photo.save
        if params[ :pic_type ] != "upload_avatar"
          @photo.update_albums(current_user.person)
        end
        @photo.process
        rounder_corner
        if params[:photo][:is_avatar]
          updateUrls(params, @photo)
        end
        respond_to do |format|
          if params[:authenticity_token] #upload with iframe
            format.html{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
          else
            format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
          end
        end
      else
        respond_with @photo, :location => photos_path, :error => message
      end
    end
  end
  
  def updateUrls(params,photo)
    url_params = {:image_url => @photo.url(:thumb_large),
                  :image_url_medium => @photo.url(:thumb_medium),
                  :image_url_small => @photo.url(:thumb_small)}
    if "event" == params[:photo][:model_name]
        if params[:photo][:is_edit] == "true" 
          Event.update_avatar_urls(params, url_params)
        end
    end 
    
    if "profile" == params[:photo][:model_name]
      current_user.profile.update_attributes(url_params)
    end

    if "group" == params[:photo][:model_name]
      if params[:photo][:is_edit] == "true"
        Group.update_avatar_urls(params, url_params)
      end
    end
  end

  private

  def rounder_corner_shell(photo_path,mask_path)
    `convert #{photo_path} #{mask_path} -alpha off -compose CopyOpacity -composite #{photo_path}`
  end

  def rounder_corner
    photo_path = {:image_url_large => 'public'+@photo.url(:thumb_large),
                  :image_url_medium =>'public'+ @photo.url(:thumb_medium),
                  :image_url_small => 'public'+@photo.url(:thumb_small)}
    rounder_corner_shell(photo_path[ :image_url_large ],'public/images/mask/large_mask.jpg')
    rounder_corner_shell(photo_path[ :image_url_medium ],'public/images/mask/medium_mask.jpg')
    rounder_corner_shell(photo_path[ :image_url_small ],'public/images/mask/small_mask.jpg')
  end

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
