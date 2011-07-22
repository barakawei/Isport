class PostVisibility < ActiveRecord::Base
  belongs_to :contact
  belongs_to :post
end
