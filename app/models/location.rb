class Location < ActiveRecord::Base
  belongs_to :city
  belongs_to :district

  has_one :events
  has_one :profiles

  def to_s 
    c_name = city ? city.name : ""
    d_name = district ? district.name : ""
    c_name + d_name + detail
  end
end
