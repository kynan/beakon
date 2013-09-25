models = require './models'
Beacon = models.beacon
User = models.user
OpenID = models.openID

db =
  findBeaconsNear: (location, radius, done) ->
    Beacon.find {location: $nearSphere: location, $maxDistance: radius}, (err, beacons) ->
      console.log "Error retrieving beacons:", err if err?
      done beacons

  findBeaconsInBox: (swlng, swlat, nelng, nelat, done) ->
    box = [[parseFloat(swlng), parseFloat(swlat)], [parseFloat(nelng), parseFloat(nelat)]]
    #Beacon.find {location: {$geoWithin: {$box: box}}}, (err, beacons) ->
    # FIXME return all results for now
    Beacon.find {}, (err, beacons) ->
      console.log "Error retrieving beacons:", err if err?
      done beacons

  findBeaconById: (id, done) ->
    Beacon.findById id, (err, beacon) ->
      console.log "Error retrieving beacon:", err if err?
      done beacon

  findBeaconsByUser: (userId, done) ->
    #Beacon.find({userId: userId}).populate('transcations').exec (err, beacons) ->
    # FIXME return all results for now
    Beacon.find({}).sort('-startDate').populate('transcations').exec (err, beacons) ->
      console.log "Error retrieving beacons:", err if err?
      done beacons

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

  saveAssociation: (handle, provider, algorithm, secret, expiresIn, done) ->
    OpenID.create {
      handle: handle,
      provider: provider,
      algorithm: algorithm,
      secret: secret,
      expires: new Date(Date.now() + 1000 * expiresIn)
    }, done

  loadAssociation: (handle, done) ->
    OpenID.findOne {handle: handle}, (error, result) ->
      if error
        return done error
      else
        return done null, result.provider, result.algorithm, result.secret

module.exports = db
