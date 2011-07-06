class Location < ActiveRecord::Base
  belongs_to :city
  belongs_to :district

  has_many :events
  has_many :profiles

  def to_s 
    city.name + district.name + detail
  end
end
