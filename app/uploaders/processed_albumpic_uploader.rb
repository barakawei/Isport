# encoding: utf-8

class ProcessedAlbumpicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :thumb_small do
    process :convert => 'jpg'
    process :shrink => 145
  end

  version :thumb_medium do
    process :convert => 'jpg'
    process :shrink => 200 
  end

  version :thumb_large do
    process :convert => 'jpg'
    process :shrink => 600
  end

  version :origin do
    process :convert => 'jpg'
  end

  version :shortcut do
    process :convert => 'jpg'
    process :resize_to_fill => [55,55] 
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
