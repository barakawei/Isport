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

function codeAddress(element,address, parent_div, zoom) {
  var z = arguments[3] ? arguments[3] : 13;
  initialize(z, element);
  
  var contentString = '<div id="content" style="width: 300px">'+
    '<div id="siteNotice">'+
    '</div>'+
    '<h4 class="blue">'+ address + '</h4>'+
    '</div>';
  
  var infowindow = new google.maps.InfoWindow({
    content: contentString 
  });
 
  
  if (geocoder) {
    geocoder.geocode({'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        map.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
            map: map, 
            position: results[0].geometry.location
        });
        
        if (element == "map-big") {
          google.maps.event.addListener(marker, 'click', function() {
           infowindow.open(map,marker);
           });
        }
        
      } else {
        document.getElementById(parent_div).style.display = 'none';
      }
    });
  }
}  

