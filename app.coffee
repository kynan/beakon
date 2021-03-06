port = process.env.PORT || 3000
host = process.env.HOST || "0.0.0.0"
baseurl = process.env.BASEURL || "http://localhost:#{port}"

generateRandomString = (length) ->
  length = length ? length : 32
  string = ''
  chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz'
  for _ in [1..length]
    randomNumber = Math.floor(Math.random() * chars.length)
    string += chars.substring(randomNumber, randomNumber + 1)
  return string


require('zappajs') host, port, ->
  manifest = require './package.json'
  db = require './db'
  fs = require 'fs'
  braintree = require 'braintree'
  mongoose = require 'mongoose'
  passport = require 'passport'
  googOID = require('passport-google').Strategy

  gateway = braintree.connect({
    environment: braintree.Environment.Sandbox,
    merchantId: "6nfqbd84b88kwvkt",
    publicKey: "vn2frdkgk7vk2bq7",
    privateKey: "4695184582ce821b4f6b45a442b98d64"
  })

  @configure =>
    @use 'cookieParser',
      'bodyParser',
      'methodOverride',
      'session': secret: 'shhhhhhhhhhhhhh!',
      passport.initialize(),
      passport.session(),
      @app.router,
      'static'
    @set 'view engine', 'jade'
    @app.engine 'html', require('ejs').renderFile

  @configure
    development: =>
      mongoose.connect "mongodb://#{host}/#{manifest.name}-dev"
      @use errorHandler: {dumpExceptions: on, showStack: on}
    production: =>
      mongoose.connect process.env.MONGOHQ_URL || "mongodb://#{host}/#{manifest.name}"
      @use 'errorHandler'

  # Authenication

  strategy = new googOID
    returnURL: "#{baseurl}/auth/google/return"
    realm: baseurl
    stateless: true
  , (identifier, profile, done) ->
    console.log 'user logged in:', identifier, profile
    db.findOrCreateUser identifier, (err, user) ->
      profile._id = identifier
      done err, profile
  strategy.saveAssociation db.saveAssociation
  strategy.loadAssociation db.loadAssociation

  passport.use strategy

  passport.serializeUser (user, done) ->
    done null, user

  passport.deserializeUser (user, done) ->
    db.findUserById user._id, done

  ensureAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
      return next()
    req.session.redirect_to = req.path
    res.redirect '/auth/google'

  @get '/auth/google', passport.authenticate 'google'
  @get '/auth/google/return', passport.authenticate('google', { failureRedirect: '/login' }), (req, res) ->
    target = req.session.redirect_to || '/'
    delete req.session.redirect_to
    res.redirect target

  @get '/': ->
    @render 'index.jade'

  @get '/beacons/add', ensureAuthenticated, ->
    @render 'add.jade'

  @get '/beacon/:id': ->
    db.findBeaconById @params.id, (beacon) =>
      console.log beacon
      @render 'product.html', {beaconId: @params.id, beacon: beacon}

  @get '/pay': ->
    @render 'payment.html', {beaconId: @query.beacon}

  @post '/pay/execute', (req, res) ->
    db.findBeaconById @body.beacon, (beacon) =>
      saleRequest = {
        amount: beacon.price,
        creditCard: {
          number: @body.ccnumber,
          cvv: @body.cvv,
          expirationMonth: @body.exp_month,
          expirationYear: @body.exp_year
        },
        options: {
          submitForSettlement: true,
          storeInVaultOnSuccess: true
        }
      }

      gateway.transaction.sale(
        saleRequest, (err, result) ->
          #console.log err, result
          if result.success
            ourTransactionId = generateRandomString(5)
            db.createTransaction 1, 1, ourTransactionId
            res.redirect '/success/'+ourTransactionId
          else
            res.send "<h1>Error:  " + result.message + "</h1>")

  @get '/success/:id': ->
    @render 'receipt.html', {transactionId: @params.id}

  # API

  @post '/beacons', ensureAuthenticated, ->
    beacon = @body
    beacon.userId = @request.user._id
    db.addBeacon beacon, (newbeacon) =>
      @response.redirect '/beacon'

  # Show the current beacon
  @get '/beacon', ensureAuthenticated, ->
    beacons = db.findBeaconsByUser @request.user._id, (beacons) =>
      @render 'active.html', {history: beacons}

  @get '/beacons': ->
    if @query.nelng and @query.nelat and @query.swlng and @query.swlat
      db.findBeaconsInBox @query.swlng, @query.swlat, @query.nelng, @query.nelat, (beacons) =>
        @response.json beacons
    else
      db.findBeaconsNear {lng: @query.lng or 51.5135, lat: @query.lat or -0.0868}, @query.radius or 100, (beacons) =>
        @response.json beacons
