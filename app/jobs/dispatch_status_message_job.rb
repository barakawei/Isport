module Job
  class DispatchStatusMessageJob
    @queue = :share
    def self.perform(post_id, recipient_user_ids)
      post = Post.find(post_id)
      create_visibilities(post, recipient_user_ids)
    end

    def self.create_visibilities(post, recipient_user_ids)
      contacts = Contact.where(:user_id => recipient_user_ids, :person_id => post.author_id)
      contacts.each do |contact|
        begin
          PostVisibility.create(:contact_id => contact.id, :post_id => post.id)
        rescue ActiveRecord::RecordNotUnique => e
          Rails.logger.info(:event => :unexpected_pv, :contact_id => contact.id, :post_id => post.id)
          #The post was already visible to that user
        end
      end
    end 
  end
end  
