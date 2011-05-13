class Event < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  mount_uploader :avatar, EventAvatarUploader
end
