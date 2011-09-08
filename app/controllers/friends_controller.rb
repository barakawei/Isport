class FriendsController < ApplicationController
  def invite
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
  end

  def find
    @except_person = current_user.followed_people + [ current_user.person ]
    @interests =  current_user.person.interests
  end
end
