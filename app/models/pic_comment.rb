class PicComment < ActiveRecord::Base
  belongs_to :pic
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"
end
