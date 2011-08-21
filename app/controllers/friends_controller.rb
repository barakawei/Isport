class FriendsController < ApplicationController
  def invite
  end

  def find
    @current_person = current_user.person
    @interests = @current_person.interests
  end
end
