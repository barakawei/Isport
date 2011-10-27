class MembershipsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :find_group, :except => [:invite]

  def create
    unless params[:selectedIds]
      @group.add_member(current_user.person)  
      redirect_to :back
    else
      @person = current_user.person
      if params[:selectedIds] && params[:selectedIds].length > 0 && @group.is_admin(@person)
        Membership.update_all ['pending = ?', false], :person_id => params[:selectedIds] 
      end
      render :nothing => true
    end
  end

  def destroy
    @person = current_user.person
    unless params[:member_ids]
      Membership.destroy_all(:group_id => @group.id, :person_id => current_user.person.id)
    else
      if @group.is_admin(@person)
        member_ids = params[:member_ids].split(',');
        Membership.destroy_all(:group_id => @group.id, :person_id => member_ids)
      end
    end
    redirect_to :back
  end

  def invite
    @person = current_user.person
    @group = Group.find(params[:id])

    if params[:selectedIds] && params[:selectedIds].length > 0 && @group.is_admin(@person)
      person_ids = params[:selectedIds].split(',');
      person_ids.each do |person_id|
        member = Membership.find_or_create_by_group_id_and_person_id(:group_id => @group.id, :person_id => person_id,
                          :pending => true, :pending_type=> Group::JOIN_BY_INVITATION_FROM_ADMIM) 
      end
    end 
    render :nothing => true
  end


  private

  def find_group
    @group = Group.find(params[:group_id])
  end
end
