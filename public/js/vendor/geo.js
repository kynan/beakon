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

  var myLatlng = new google.maps.LatLng(-54.363882, -0.044922);

  var contentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">Uluru</h1>'+
      '<div id="bodyContent">'+
      '<p><b>Uluru</b>, also referred to as <b>Ayers Rock</b>, is a large ' +
      'sandstone rock formation in the southern part of the '+
      'Northern Territory, central Australia. It lies 335&#160;km (208&#160;mi) '+
      'south west of the nearest large town, Alice Springs; 450&#160;km '+
      '(280&#160;mi) by road. Kata Tjuta and Uluru are the two major '+
      'features of the Uluru - Kata Tjuta National Park. Uluru is '+
      'sacred to the Pitjantjatjara and Yankunytjatjara, the '+
      'Aboriginal people of the area. It has many springs, waterholes, '+
      'rock caves and ancient paintings. Uluru is listed as a World '+
      'Heritage Site.</p>'+
      '<p>Attribution: Uluru, <a href="http://en.wikipedia.org/w/index.php?title=Uluru&oldid=297882194">'+
      'http://en.wikipedia.org/w/index.php?title=Uluru</a> '+
      '(last visited June 22, 2009).</p>'+
      '</div>'+
      '</div>';

  var infowindow = new google.maps.InfoWindow({
      content: contentString
  });

  var marker = new google.maps.Marker({
      position: myLatlng,
      map: map,
      title: 'Uluru (Ayers Rock)'
  });
  google.maps.event.addListener(marker, 'click', function() {
    infowindow.open(map,marker);
  });


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
