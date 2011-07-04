/**
 * mark the address on the google map
 * paramter: address
 */

var geocoder;
var map;
function initialize(zoom,element) {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(32.060255, 118.796877);
  var myOptions = {
    zoom: zoom,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  map = new google.maps.Map(document.getElementById(element), myOptions);
}

function codeAddress(element,address, zoom) {
 var z = arguments[2] ? arguments[2] : 13;
  initialize(z, element);
  if (geocoder) {
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        map.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
            map: map, 
            position: results[0].geometry.location
        });
      } else {
        alert("Geocode was not successful for the following reason: " + status);
      }
    });
  }
}  

