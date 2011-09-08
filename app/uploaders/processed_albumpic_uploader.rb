# encoding: utf-8

class ProcessedAlbumpicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :thumb_small do
    process :shrink
    process :convert => 'png'
  end


  def store_dir
    "uploads/albums"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    if @filename
      filename = @filename.split('.')[ 0 ]+'.png'
    end
    model.random_string + File.extname(filename) if filename
  end


  private

  def shrink
    manipulate! do |img|
      w,h = img['%w %h'].split
      w = w.to_f
      h = w.to_f
      @@max_size = 140

     if (w > @@max_size || h > @@max_size)
        if (w > h)
          h = (h*(@@max_size/w)).to_i
          w = @@max_size
        else
          w = (w*(@@max_size/h)).to_i
          h = @@max_size
        end
        img.resize "#{w}x#{h}"
        img
      else
        img
      end
    end
  end 
end
