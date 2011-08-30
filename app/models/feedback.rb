class Feedback < ActiveRecord::Base
  belongs_to :person

  scope :processed, lambda { where('processed = ?', true) } 
  scope :not_processed, lambda { where('processed = ?', false) } 
end
