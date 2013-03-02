port = process.env.PORT || 3000
host = process.env.HOST || "0.0.0.0"

require('zappajs') host, port, ->
  manifest = require './package.json'
  fs = require 'fs'

  @configure =>
    @use 'cookieParser',
      'bodyParser',
      'methodOverride',
      'session': secret: 'shhhhhhhhhhhhhh!',
      @app.router,
      'static'
    @set 'view engine', 'jade'

  @configure
    development: =>
      @use errorHandler: {dumpExceptions: on, showStack: on}
    production: =>
      @use 'errorHandler'

  @get '/': ->
    @response.redirect '/home'

  @get '/home': ->
    md = require('node-markdown').Markdown
    fs.readFile 'README.md', 'utf-8', (err, data) =>
      @render 'markdown.jade', {md: md, markdownContent: data, title: manifest.name, id: 'home', brand: manifest.name}

  @get '/source': ->
    @response.redirect manifest.source
