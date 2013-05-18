port = process.env.PORT || 3000
host = process.env.HOST || "127.0.0.1"
baseurl = process.env.BASEURL || "http://#{host}:#{port}"

require('zappajs') host, port, ->
  manifest = require './package.json'
  db = require './db'
  fs = require 'fs'
  mongoose = require 'mongoose'
  passport = require 'passport'
  googOID = require('passport-google').Strategy

  passport.use new googOID
    returnURL: "#{baseurl}/auth/google/return"
    , realm: baseurl
    , (identifier, profile, done) ->
      console.log 'user logged in:', identifier, profile
      db.findOrCreateUser identifier, (err, user) ->
        profile._id = identifier
        done err, profile

  passport.serializeUser (user, done) ->
    done null, user

  passport.deserializeUser (user, done) ->
    db.findUserById user._id, done

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

  @get '/auth/google', passport.authenticate 'google'
  @get '/auth/google/return', passport.authenticate 'google', { successRedirect: '/', failureRedirect: '/login' }

  @get '/': ->
    @render 'index.jade'

  @get '/beacons/add': ->
    @render 'add.jade'

  @get '/home': ->
    md = require('node-markdown').Markdown
    fs.readFile 'README.md', 'utf-8', (err, data) =>
      @render 'markdown.jade', {md: md, markdownContent: data, title: manifest.name, id: 'home', brand: manifest.name}

  @get '/source': ->
    @response.redirect manifest.source

  # API

  @post '/beacons': ->
    db.addBeacon @body, (newbeacon) =>
      @response.json newbeacon

  @get '/beacons': ->
    db.findBeaconsNear {lng: @query.lng or 51.5135, lat: @query.lat or -0.0868}, @query.radius or 100, (beacons) =>
      @response.json beacons
