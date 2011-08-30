class FriendsController < ApplicationController
  def invite
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
  end

  def find
    @current_person = current_user.person
    @interests = @current_person.interests
  end
end
