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
    e.use express.favicon()
    e.use express.logger('dev') if e.get('env') is 'development'
    e.use express.bodyParser()
    e.use express.methodOverride()
    e.use express.cookieParser @config.cookieSecret
    e.use express.session()
    e.use e.router
    e.use '/s', express.static __dirname + '/../static'

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
