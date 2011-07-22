class Location < ActiveRecord::Base
  belongs_to :city
  belongs_to :district

  has_one :events
  has_one :profiles
  has_one :group

  def to_s 
    city.name + district.name + detail
  end
end