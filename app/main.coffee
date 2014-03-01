fs = require 'fs'
App = require './App'

config = JSON.parse fs.readFileSync(__dirname + '/../config.json')

app = new App config
app.start ->
