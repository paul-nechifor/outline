projectName = 'outline'

config =
  minify: false
  port: 3000
  cookieSecret: 'cookie secret'

  bower:
    name: projectName
    version: '0.0.1'
    dependencies:
      bootstrap: '>=3.1.1'

  packageJson:
    name: projectName
    version: '0.0.1'
    private: false # Maybe you need to change it?
    dependencies:
      express: '3.4.5'
      jade: '*'
      request: '>=2.34.0'
      soap: '>=0.4.0'
      ws: '>=0.4.30'
    devDependencies:
      stylus: '*'
      browserify: '>=3.31.2'
      coffeeify: '>=0.6.0'
      'uglify-js': '2.4.12'

# Let the secret file alter the config if it exists.
if require('fs').existsSync('./secret.coffee')
  require('./secret.coffee')(config)

module.exports = config
