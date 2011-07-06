class Comment < ActiveRecord::Base
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"
  belongs_to :post,:touch => true
end
