function createMap() {
    var mapcanvas = document.createElement('div');
    mapcanvas.id = 'mapcanvas';
    mapcanvas.style.height = '100%';
    mapcanvas.style.width = '100%';
    document.querySelector('#mapbg').appendChild(mapcanvas);

    var map = new google.maps.Map(document.getElementById("mapcanvas"), {
        zoom: 15,
        disableDefaultUI: true,
        mapTypeControl: false,
        navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
        mapTypeId: google.maps.MapTypeId.ROADMAP
    });
};

function loadLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function() {
        $('#status').hide();

          var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);

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

function init() {
    createMap();
    loadLocation();
}

$(function() {
    init();
});
