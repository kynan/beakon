(function() {

var map;
var beacons = new Array();

function createMap() {
  var mapcanvas = document.createElement('div');
  mapcanvas.id = 'mapcanvas';
  mapcanvas.style.height = '100%';
  mapcanvas.style.width = '100%';
  document.querySelector('#mapbg').appendChild(mapcanvas);

  map = new google.maps.Map(document.getElementById("mapcanvas"), {
    zoom: 15,
    center: new google.maps.LatLng(-34.397, 150.644),
    disableDefaultUI: true,
    mapTypeControl: false,
    navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
}

function loadUserLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      $('#status').hide();

      var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      map.setCenter(latlng);

      var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        title:"You are here! (at least within a "+position.coords.accuracy+" meter radius)"
      });
    }, function() {
      // TODO: You can't really use the app without a location
    });
  } else {
    // TODO: You can't really use the app
  }
}

var reloadTimeout;
function setupEvents() {
  google.maps.event.addListener(map, 'bounds_changed', function() {
    if (reloadTimeout)
      clearTimeout(reloadTimeout);
    reloadTimeout = window.setTimeout(function() {
      // Clear all existing markers
      $.each(beacons, function(_, beacon) {
        beacon.setMap(null);
      });

      // Create new markers
      function getRandomInRange(from, to, fixed) {
        return (Math.random() * (to - from) + from).toFixed(fixed) * 1;
        // .toFixed() returns string, so ' * 1' is a trick to convert to number
      }
      function r() {return getRandomInRange(-180, 180, 3);}
      var data = [{lat: r(), long: r()}, {lat: r(), long: r()}, {lat: r(), long: r()}, {lat: r(), long: r()}];

      var marker;
      for (i = 0; i < data.length; i++) {
        var item = data[i];
        marker = new google.maps.Marker({
          position: new google.maps.LatLng(item.lat, item.long),
          map: map,
          title:"dummy"
        });
        beacons.push(marker);
      }
    }, 500);
  });
}

function init() {
  createMap();
  loadUserLocation();
  setupEvents();
}

$(function() {
  init();
});


})();
