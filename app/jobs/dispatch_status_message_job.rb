module Job
  class DispatchStatusMessageJob
    @queue = :share
    def self.perform(post_id, recipient_person_ids)
      post = Post.find(post_id)
      create_visibilities(post, recipient_person_ids)
    end

    def self.create_visibilities(post, recipient_person_ids)
      recipient_person_ids.each do |person_id|
        PostVisibility.create(:person_id => person_id, :post_id => post.id)
      end
    end 
  end
end  
