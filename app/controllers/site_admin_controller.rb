class SiteAdminController < ApplicationController
  before_filter :is_admin
  def feedbacks_admin
    @feedbacks = Feedback.paginate :page => params[:page], :per_page => 15, :order => 'created_at desc' 
  end

  def events_admin
    @events =  Event.paginate :page => params[:page], :per_page => 15, :order => 'created_at desc' 
  end

  def groups_admin
    @groups=  Group.paginate :page => params[:page], :per_page => 15, :order => 'created_at desc' 
  end

  def get_events_count_ajax
    @count = Event.where(:status => Event::BEING_REVIEWED).count
    render :text => @count
  end

  def get_groups_count_ajax
    @count = Group.where(:status => Group::BEING_REVIEWED).count
    render :text => @count
  end

  def deny_event
    msg = params[:reason]
    event = Event.find(params[:event_id])
    unless event.status == Event::DENIED
      event.update_attributes(:status => Event::DENIED,:status_msg => msg, :audit_person_id => current_user.person.id)
    end
    render :partial => 'event_audit_block', :locals => {:e => event}
  end

  def pass_event
    event = Event.find(params[:event_id])
    event.update_attributes(:status => Event::PASSED)
    render :partial => 'event_audit_block', :locals => {:e => event}
  end

  def delete_event
    event = Event.find(params[:event_id])
    event.destroy
    render :nothing => true
  end

  def deny_group
    msg = params[:reason]
    group = Group.find(params[:group_id])
    unless group.status == Group::DENIED
      group.update_attributes(:status => Group::DENIED, :status_msg => msg, :audit_person_id => current_user.person.id)
    end
    render :partial => 'group_audit_block', :locals => {:g => group}
  end

  def pass_group
    group = Group.find(params[:group_id])
    group.update_attributes(:status => Group::PASSED, :audit_person_id => current_user.person.id)
    render :partial => 'group_audit_block', :locals => {:g => group}
  end

  def delete_group
    group = Group.find(params[:group_id])
    group.destroy
    render :nothing => true
  end

  private 

  def is_admin
    raise ActionController::RoutingError.new("not such route") unless current_user.try(:admin?)
  end
end
