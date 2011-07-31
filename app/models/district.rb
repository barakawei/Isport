class District < ActiveRecord::Base
  belongs_to :city
  has_many :locations
  has_many :groups
end
