# encoding: utf-8

class ProcessedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
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

  version :thumb_small do
    process :convert => 'png'
    process :resize_to_fill => [50,50] 
  end
  version :thumb_medium do
    process :convert => 'png'
    process :resize_to_fill => [100,100]
  end
  version :thumb_large do
    process :convert => 'png'
    process :resize_to_fill => [200,200]
  end
  
end
