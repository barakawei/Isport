module ItemsHelper
  def is_fan_of(item)  
    unless current_user
      false
    else
      item.fans.include?(current_user.person) 
    end
  end

  def is_admin
    unless current_user
      false
    else
      Administrator.find_by_user_id(current_user.person.user_id) ? true : false
    end
  end
end
