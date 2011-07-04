class City < ActiveRecord::Base
  has_many :districts
  has_many :locations
end
