class City < ActiveRecord::Base
  has_many :districts
  has_many :locations
  has_many :groups

  belongs_to :province
end
