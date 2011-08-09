class MembershipsController < ApplicationController
  before_filter :find_group, :except => [:invite]

  def create
    @group.add_member(current_user.person)  
    redirect_to :back
  end

  def destroy
    @person = current_user.person
    unless params[:member_ids]
      @group.delete_member(current_user.person)
    else
      unless @group.is_admin(@person)
      else
        member_ids = params[:member_ids].split(',');
        Membership.delete_all(:group_id => @group.id, :person_id => member_ids)
      end
    end
    redirect_to :back
  end

  def invite
    @person = current_user.person
    @group = Group.find(params[:id])

    if params[:selectedIds] && params[:selectedIds].length > 0
      person_ids = params[:selectedIds].split(',');
      person_ids.each do |person_id|
        Membership.create(:group_id => @group.id, :person_id => person_id,
                          :pending => true, :join_mode => @group.join_mode)
      end
    end 
    render :nothing => true
  end

  private

  def find_group
    @group = Group.find(params[:group_id])
  end
end
