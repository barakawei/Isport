class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?

  def show
    @topic = ItemTopic.find(params[:id]) 

  end

  def filter 
    @person = current_user.person
    @item_topics = ItemTopic.send(params[:target], @person).send(params[:order])
    render :partial => 'filter', :locals => {:topics => @item_topics}
  end

  def create
    @current_person = current_user.person
    @topic = ItemTopic.new(params[:item_topic])
    @topic.person = @current_person  
    puts params[:format]
    if @topic.save
      if params[:format] == 'json'  
        render :xml=> @topic.to_xml
      else
        redirect_to item_topic_path(@topic)
      end
    else
      respond_to do |format|
        format.html{ render :action => :new }
        format.json { render :text => @topic.to_json }
      end
    end
  end

end
