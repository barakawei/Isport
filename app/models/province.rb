class Province < ActiveRecord::Base
  has_many :cities, :dependent => :destroy

end
