class PostVisibility < ActiveRecord::Base
  belongs_to :person
  belongs_to :post
end
