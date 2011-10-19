class City < ActiveRecord::Base
  has_many :districts, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :groups, :dependent => :destroy

  belongs_to :province
end
