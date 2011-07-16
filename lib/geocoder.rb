#encoding: utf-8
require 'net/http'
require 'uri'
require 'rubygems'
require 'builder'
require 'cgi'
require 'json'

class GoogleGeoCoder
  GEOCODER = "http://ditu.google.cn/maps/api/geocode/json?address="
  SENSOR = "&sensor=false" 

  def self.getLocation(addr)
  	url = GEOCODER + CGI.escape(addr) + SENSOR
	resp = Net::HTTP.get_response(URI.parse(url))
	result = JSON.parse(resp.body)
	if (result["status"] == "OK") 
	  return result["results"][0]["geometry"]["location"]
	end
	return nil
  end
end




