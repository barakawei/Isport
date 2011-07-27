class MembershipsController < ApplicationController
  before_filter :find_group, :except => [:invite]

  def create
    @group.add_member(current_user.person)  
    redirect_to :back
  end

  def destroy
    @group.delete_member(current_user.person)
    redirect_to :back
  end

  def invite
    @person = current_user.person
    @group = Group.find(params[:id])

    if params[:selectedIds] && params[:selectedIds].length > 0
      person_ids = params[:selectedIds].split(',');
      person_ids.each do |person_id|
        Membership.create(:group_id => @group.id, :person_id => person_id,
                          :pending => true)
      end
    end 
    render :nothing => true
  end

  private

  def find_group
    @group = Group.find(params[:group_id])
  end
end
