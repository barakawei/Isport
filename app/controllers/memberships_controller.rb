class MembershipsController < ApplicationController
  before_filter :find_group

  def create
    @group.add_member(current_user.person)  
    redirect_to :back
  end

  def destroy
    @group.delete_member(current_user.person)
    redirect_to :back
  end

  private

  def find_group
    @group = Group.find(params[:group_id])
  end
end
