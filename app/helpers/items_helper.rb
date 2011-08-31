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
      current_user.try(:admin?)
    end
  end
end
