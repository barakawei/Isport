# encoding: utf-8

class ProcessedAlbumpicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :thumb_small do
    process :convert => 'jpg'
    process :shrink => 140
  end

  version :thumb_medium do
    process :convert => 'jpg'
    process :shrink => 180 
  end

  version :thumb_large do
    process :convert => 'jpg'
    process :shrink => 640 
  end

  version :origin do
    process :convert => 'jpg'
  end

  def store_dir
    "uploads/albums"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    if @filename
      filename = @filename.split('.')[ 0 ]+'.jpg'
    end
    model.random_string + File.extname(filename) if filename
  end


  private

  def shrink(size)
    manipulate! do |img|
      w,h = img['%w %h'].split
      w = w.to_f
      h = w.to_f

     if (w > size || h > size)
        if (w > h)
          h = (h*(size/w)).to_i
          w = size
        else
          w = (w*(size/h)).to_i
          h = size
        end
        img.resize "#{w}x#{h}"
        img
      else
        img
      end
    end
  end 
end