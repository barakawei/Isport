class Authorization < ActiveRecord::Base
  belongs_to :user
  
  validate :user_id, :uid, :provider, :presence => true
  validate :uid, :uniqueness => { :scope => :provider } 
end
