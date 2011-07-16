class LocationController < ApplicationController
  def districts_of_city
    @districts = District.where(:city_id => params[:id])
    render :partial => "districts_select", :locals => {:name => params[:select_name]}
  end
end
