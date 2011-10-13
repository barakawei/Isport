class FriendsController < ApplicationController
  def invite
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
  end

  def find
    city_id = params[:city] ? params[:city] : (current_user ? current_user.city.id : City.first.id)
    @city = City.find(city_id)

    @except_person = current_user.followed_people + [ current_user.person ]
    @interests =  current_user.person.interests
  end
end
