class City < ActiveRecord::Base
  has_many :districts
  has_many :locations
  has_many :groups
end
