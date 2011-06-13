class Favorite < ActiveRecord::Base
  belongs_to :person
  belongs_to :item
end
