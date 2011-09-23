class Themefollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :theme, :counter_cache => :followers_count

end
