class UsersController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!, :except => [:new, :create, :public]
  before_filter :is_admin,:only => :online_user
  
  def getting_started
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    @user = current_user
    @person = @user.person
    @profile = @user.profile
    @profile.location = Location.new if @profile.location.nil?
    @city = @profile.location.city
    @province = @city ? @city.province : nil
    render "users/getting_started"
  end


  def edit
    @user = current_user
    @profile = @user.profile
    render "users/getting_started"
  end

  def select_interests
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    @items = Item.all
    @my_items = current_user.person.interests
    @items.each do |item|
      item.selected = true if @my_items.include?(item)
    end
  end

  def select_interested_people
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    current_user.update_attributes(:getting_started => false)
    group = Group.where(:id => 2)
    group.first.members << current_user.person if group.size > 0
  end

  def change_password
    render 'devise/passwords/change_password.html.haml' 
  end

  def set_account
    @user = current_user
    @auth = @user.authorizations.first
    @skip_binding = @auth && @auth.bind_status == Authorization::SKIP_BINDING
    @current_pass = @skip_binding ? '...' : '' 
    @weibo_user = @auth.get_details if @auth
    @weibo_name = @weibo_user.name if @weibo_user
  end

  
  def weibo_already_binded_error 
    @user = current_user
    @error = I18n.t('activerecord.errors.messages.bind_alreay_exist')
    @skip_binding = true
    @current_pass = '...'
    render 'set_account' 
  end

  def potential_interested_people
    person = current_user.person 
    @people = Person.potential_interested_people_limit(current_user.person)
    render :partial => 'people/potential_interested_people',  :locals => { :people => @people}
  end

  def update_password
    @user = current_user
    @auth = @user.authorizations.first 
    params['current_password'] = '3275315321' if @auth.bind_status == Authorization::SKIP_BINDING 
    if @user.update_with_password(params)
      @auth.update_attributes(:bind_status => Authorization::BINDED) if @auth.bind_status == Authorization::SKIP_BINDING
      sign_in(@user, :bypass => true)
      redirect_to root_path, :notice => "Password updated!"
    else
      render 'set_account' 
    end
  end

  def update_email
    email = params[:email] 
    @user = current_user
    if User.where(:email => email).size > 0 && email != @user.email
      @user.errors[:email] = I18n.t('activerecord.errors.messages.already_used')
      @user.email = email
      render 'set_account' 
    else
      if @user.update_attributes(:email => email)
        redirect_to root_path     
      else
        render 'set_account'
      end
    end
  end

  def delete_auth
    current_user.authorizations.first.destroy 
    redirect_to :back
  end

  

  def online_user
   @online_user = Person.joins(:user).joins( :profile ).where(["last_request_at > ?", 5.minutes.ago]).where("location_id is not null").paginate(:page => params[:page], :per_page => 100)
  end

  def validate_email
    email = params[:email]
    if User.where(:email => email).size > 0 && email != current_user.email
      render :text => 'false' 
    else
      render :text => 'true' 
    end
  end

  def validate_email_exist
    email = params[:email]  
    if User.where(:email => email).size > 0
      render :text => 'true' 
    else
      render :text => 'false' 
    end
  end
  
end
