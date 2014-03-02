name = 'outline'

config =
  name: name
  minify: false
  port: 3000
  cookieSecret: 'cookie secret'

  deploy:
    server: 'example.com'
    user: 'p'
    installPath: '/home/p/pro/' + name
    supervisorScript: null
    run: 'app/main.js'

  bower:
    name: name
    version: '0.0.1'
    dependencies:
      bootstrap: '>=3.1.1'

  packageJson:
    name: name
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
      control: '>=0.2.3'

config.deploy.supervisorScript =
  """
  [program:#{name}]
  command=#{config.deploy.installPath}/#{config.deploy.run}
  autostart=true
  autorestart=true
  stderr_logfile=/var/log/#{name}.err.log
  stdout_logfile=/var/log/#{name}.out.log

  """

# Let the secret file alter the config if it exists.
if require('fs').existsSync('./secret.coffee')
  require('./secret.coffee')(config)

module.exports = config
