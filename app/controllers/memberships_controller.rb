class MembershipsController < ApplicationController
  def create
    @group = Group.find(params[:group_id])
    @group.add_member(current_user.person)  
    redirect_to :back
  end

  def destroy
    @group = Group.find(params[:group_id])
    @group.delete_member(current_user.person)
    redirect_to :back
  end
end
