port = process.env.PORT || 3000
host = process.env.HOST || "0.0.0.0"

require('zappajs') host, port, ->
  manifest = require './package.json'
  db = require './db'
  fs = require 'fs'
  mongoose = require 'mongoose'

  @configure =>
    @use 'cookieParser',
      'bodyParser',
      'methodOverride',
      'session': secret: 'shhhhhhhhhhhhhh!',
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

  @get '/': ->
    @render 'index.html'

  @get '/beacons': ->
    db.findBeaconsNear {lng: @query.lng or 51.5135, lat: @query.lat or -0.0868}, @query.radius or 100, (beacons) =>
      @response.json beacons

  @get '/home': ->
    md = require('node-markdown').Markdown
    fs.readFile 'README.md', 'utf-8', (err, data) =>
      @render 'markdown.jade', {md: md, markdownContent: data, title: manifest.name, id: 'home', brand: manifest.name}

  @get '/source': ->
    @response.redirect manifest.source
