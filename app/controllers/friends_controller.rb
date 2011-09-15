class FriendsController < ApplicationController
  def invite
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
  end

  def find
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)

    @except_person = current_user.followed_people + [ current_user.person ]
    @interests =  current_user.person.interests
  end
end
