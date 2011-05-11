class HomeController < ApplicationController
  def index
    if current_user
      if (current_user.getting_started == true)
        redirect_to getting_started_path
      return
    end
      
    end
  end
end
