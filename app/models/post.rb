class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'

  def self.diaspora_initialize params
    new_post = self.new params.to_hash
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
    new_post.diaspora_handle = new_post.author.diaspora_handle
    new_post
  end
  
  
  def as_json(opts={})
    {
        :post => {
          :id     => self.id
        }
    }
  end  
  

end
