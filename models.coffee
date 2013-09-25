mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
  _id: String
  beacons: [{ type: mongoose.Schema.ObjectId, ref: 'Beacon' }]

BeaconSchema = new mongoose.Schema
  identifier: String
  location:
    type:
      lng: Number
      lat: Number
    index: '2d'
  startDate:
    type: Date
    default: Date.now
  endDate:
    type: Date
    default: Date.now
  userId: { type: String, ref: 'User' }
  price: Number
  quantity: Number
  title: String
  description: String
  image: String # URL for now
  active: Boolean
  transactions: [{ type: mongoose.Schema.ObjectId, ref: 'Transaction' }]

TransactionSchema = new mongoose.Schema
  identifier: String
  beaconId: { type: mongoose.Schema.ObjectId, ref: 'Beacon' }
  buyerId: { type: mongoose.Schema.ObjectId, ref: 'User' }
  quantity: Number
  date:
    type: Date
    default: Date.now

OpenIDSchema = new mongoose.Schema
  handle: String
  provider: String
  algorithm: String
  secret: String
  expires:
    type: Date
    default: Date.now
OpenIDSchema.index expires: 1, expireAferSeconds: 0, (err, res) ->
  if err
    throw new Error 'Error setting TTL index on OpenID collection.'

User = mongoose.model 'User', UserSchema
Beacon = mongoose.model 'Beacon', BeaconSchema
Transaction = mongoose.model 'Transaction', TransactionSchema
OpenID = mongoose.model 'OpenID', OpenIDSchema

module.exports.user = User
module.exports.beacon = Beacon
module.exports.transaction = Transaction
module.exports.openID = OpenID
