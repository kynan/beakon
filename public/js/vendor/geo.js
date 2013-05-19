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

function initMap(coords) {
  $('#status').hide();

  var latlng = new google.maps.LatLng(coords.latitude, coords.longitude);
  map.setCenter(latlng);

  var marker = new google.maps.Marker({
    position: latlng,
      map: map,
      title:"You are here! (at least within a "+coords.accuracy+" meter radius)"
  });
}

function loadUserLocation() {
  if (sessionStorage.coords) {
    initMap(JSON.parse(sessionStorage.coords));
  } else {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        sessionStorage.coords = JSON.stringify({latitude: position.coords.latitude,
          longitude: position.coords.longitude, accuracy: position.coords.accuracy});
        console.log(position);
        console.log(sessionStorage);
        initMap(position.coords);
      }, function() {
        // TODO: You can't really use the app without a location
      });
    } else {
      // TODO: You can't really use the app
    }
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

      var currentBounds = map.getBounds();
      $.ajax({
        dataType: "json",
        url: '/beacons',
        type: 'GET',
        data: {
          swlng: currentBounds.getSouthWest().lng(),
          swlat: currentBounds.getSouthWest().lat(),
          nelng: currentBounds.getNorthEast().lng(),
          nelat: currentBounds.getNorthEast().lat()
        },
        success: function(data) {
          var marker;
          for (i = 0; i < data.length; i++) {
            var item = data[i];
            marker = new google.maps.Marker({
              position: new google.maps.LatLng(item.location.lng, item.location.lat),
              map: map,
              title:"dummy"
            });
            google.maps.event.addListener(marker, 'click', function() {
              window.location.href = '/beacon/'+item._id
            });
            beacons.push(marker);
          }
        }});
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
