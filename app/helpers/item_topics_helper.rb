module ItemTopicsHelper
  def is_follower_of(topic)
    unless current_user
      false
    else
      topic.followers.include?(current_user.person)
    end
  end
end
