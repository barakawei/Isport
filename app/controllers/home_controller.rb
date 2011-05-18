class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    if current_user
      if (current_user.getting_started == true)
        redirect_to getting_started_path
        return
      end
      @person = current_user.person
      @contacts = current_user.contacts
      render
    end
  end
end
