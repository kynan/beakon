models = require './models'
Beacon = models.beacon

module.exports =
  findBeaconsNear: (location, radius, done) ->
    Beacon.find {location: $nearSphere: location, $maxDistance: radius}, (err, beacons) ->
      console.log "Error retrieving beacons:", err if err?
      done beacons
