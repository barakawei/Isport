class PicComment < ActiveRecord::Base
  belongs_to :pic
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"

  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  def update_owner_counter
    self.pic.comments_count = self.pic.comments.count
    self.pic.save
  end 
end
