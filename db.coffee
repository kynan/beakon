models = require './models'
Beacon = models.beacon
User = models.user

db =
  findBeaconsNear: (location, radius, done) ->
    Beacon.find {location: $nearSphere: location, $maxDistance: radius}, (err, beacons) ->
      console.log "Error retrieving beacons:", err if err?
      done beacons

  findBeaconById: (id, done) ->
    Beacon.findById id, (err, beacon) ->
      console.log "Error retrieving beacon:", err if err?
      done beacon

  addBeacon: (beacon, done) ->
    beacon.endDate = Date.now() + parseInt(beacon.expiry) * 3600 * 1000
    Beacon.create beacon, (err, newbeacon) ->
      console.log "Error creating beacon", beacon, ":", err if err?
      done newbeacon

  findUserById: (id, done) ->
    User.findById id, (err, user) ->
      console.log "Error retrieving user:", err if err?
      done err, user

  findOrCreateUser: (id, done) ->
    db.findUserById id, (err, user) ->
      done err, user if user?
      if not user
        User.create {_id: id}, (err, newuser) ->
          console.log "Error creating user", {_id: id}, ":", err if err?
          done err, newuser

  createTransaction: (beaconId, buyerId, transactionId) ->
    Beacon.create {
      identifier: transactionId,
      beaconId: beaconId,
      buyerId: buyerId
    }

module.exports = db
