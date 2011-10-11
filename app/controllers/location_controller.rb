class LocationController < ApplicationController
  before_filter :registrations_closed?
  def districts_of_city
    @districts = District.where(:city_id => params[:id])
    render :partial => "districts_select", :locals => {:name => params[:select_name]}
  end

  def cities_of_province
    @cities = City.where(:province_id => params[:id]) 
    render :partial => "cities_select", :locals => {:name => params[:select_name]}
  end
end
