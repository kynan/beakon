mongoose = require 'mongoose'

UserSchema = new mongoose.Schema
  _id: String
  beacons: [{ type: mongoose.Schema.ObjectId, ref: 'Beacon' }]

BeaconSchema = new mongoose.Schema
  identifier: String
  userId: { type: mongoose.Schema.ObjectId, ref: 'User' }
  title: String
  description: String
  address: String
  phone: String
  email: String
  startDate:
    type: Date
    default: Date.now
  endDate:
    type: Date
    default: Date.now
  location:
    type:
      lng: Number
      lat: Number
    index: '2d'
  radius: Number
  hidden: Boolean
  active: Boolean
  offers: [{ type: mongoose.Schema.ObjectId, ref: 'Offer' }]

OfferSchema = new mongoose.Schema
  identifier: String
  beaconId: { type: mongoose.Schema.ObjectId, ref: 'Beacon' }
  price: Number
  quantity: Number
  title: String
  description: String
  image: String # URL for now
  active: Boolean
  transactions: [{ type: mongoose.Schema.ObjectId, ref: 'Transaction' }]

TransactionSchema = new mongoose.Schema
  identifier: String
  offerId: { type: mongoose.Schema.ObjectId, ref: 'Offer' }
  buyerId: { type: mongoose.Schema.ObjectId, ref: 'User' }
  quantity: Number
  date:
    type: Date
    default: Date.now

User = mongoose.model 'User', UserSchema
Beacon = mongoose.model 'Beacon', BeaconSchema
Offer = mongoose.model 'Offer', OfferSchema
Transaction = mongoose.model 'Transaction', TransactionSchema

module.exports.user = User
module.exports.beacon = Beacon
module.exports.offer = Offer
module.exports.transaction = Transaction
