class Location < ActiveRecord::Base
  belongs_to :city
  belongs_to :district

  has_many :events

  def to_s 
    city.name + district.name + detail
  end

end
