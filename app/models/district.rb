class District < ActiveRecord::Base
  belongs_to :city
  has_many :locations, :dependent => :destroy
  has_many :groups, :dependent => :destroy
end
