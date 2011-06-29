# encoding: utf-8

class UnprocessedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end
end
