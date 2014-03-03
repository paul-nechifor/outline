express = require 'express'
http = require 'http'

class App
  constructor: (config) ->
    @config = config
    @express = null
    @server = null

  start: (cb) ->
    @express = express()
    @configure()
    @registerRoutes()
    @createServer cb

  stop: ->

  configure: ->
    e = @express

    e.set 'port', @config.port
    e.set 'views', __dirname + '/../views'
    e.set 'view engine', 'jade'

    # Add date logger token.
    express.logger.token 'date', -> new Date().toISOString()
    e.use express.logger @config.loggerFormat

    e.use express.favicon()
    e.use express.urlencoded()
    e.use express.json()
    e.use express.methodOverride()
    e.use express.cookieParser @config.cookieSecret
    e.use express.session()
    e.use '/s', express.static __dirname + '/../static'
    e.use e.router

  registerRoutes: ->
    e = @express

    index = require('../routes/index') this

    e.get '/', index.index

  createServer: (cb) ->
    @server = http.createServer @express
    @server.listen @config.port, =>
      console.log @config.name, 'server listening on', @config.port
      cb()

module.exports = App;
