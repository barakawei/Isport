class MessagesController < ApplicationController
  before_filter :authenticate_user!
  def create
    cnv = Conversation.joins(:conversation_visibilities).where(:id => params[:conversation_id],:conversation_visibilities => {:person_id => current_user.person.id}).first

    if cnv
      message = Message.new(:conversation_id => cnv.id, :text => params[:message][:text], :person => current_user.person)
      
      if message.save
        ConversationVisibility.connection.execute(" update conversation_visibilities set unread= unread +1 where conversation_id ="+cnv.id.to_s+" and person_id !="+current_user.person.id.to_s  );

        redirect_to conversations_path(:conversation_id => cnv.id)
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end 
  
end
