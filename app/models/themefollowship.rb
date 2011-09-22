class Themefollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :theme

end
