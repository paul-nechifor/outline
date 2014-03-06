require('coffee-script').register()
fs = require 'fs'
Build = require('web-build-tools').Build
{sh, cmd} = Build

config = require './config'

option '-m', '--minify', 'Minify the client on build.'

processOptions = (options) ->
  config.debug = options.debug if options.debug? isnt undefined

b = new Build task, config, processOptions,
  init: (cb) ->
    b.run ['clean', 'npm', 'bower'], cb

  clean: (cb) ->
    keep =
      'node_modules': true
    sh 'mkdir build 2>/dev/null; true', ->
      subs = fs.readdirSync('build')
      subs = ('build/' + f for f in subs when not keep[f])
      return cb() if subs.length == 0
      subs.splice 0, 0, '-rf'
      cmd 'rm', subs, cb

  bower: (cb) ->
    Build.writeJson 'bower.json', config.bower
    sh 'bower install', cb

  npm: (cb) ->
    Build.writeJson 'package.json', config.packageJson
    sh 'npm install', ->
      sh 'rsync -a --del node_modules/ build/node_modules/', cb

  build: (cb) ->
    b.run ['clean', 'copyFiles', 'compileApp', 'compileRoutes', 'compileStylus',
        'commandify', 'browserify', 'writeConfig'], cb

  run: (cb) ->
    cmd 'node', ['build/app/main.js'], cb

  copyFiles: (cb) ->
    sh """
      mkdir -p build/static/b/css build/static/b/js 2>/dev/null
      rsync -a --del node_modules/ build/node_modules/
      cp -r static/ build/
      cp -r views build/views
      cd bower_components/bootstrap/dist
      cp -r fonts ../../../build/static/b
      cp css/bootstrap.min.css ../../../build/static/b/css
      cp js/bootstrap.min.js ../../../build/static/b/js
    """, cb

  compileApp: (cb) ->
    sh 'coffee --compile --bare --output build/app app', cb

  compileRoutes: (cb) ->
    sh 'coffee --compile --bare --output build/routes routes', cb

  compileStylus: (cb) ->
    Build.stylus 'build/static/main.css', 'styles/main.styl', config, cb

  commandify: (cb) ->
    Build.commandify 'build/app/main.js', cb

  browserify: (cb) ->
    Build.browserify 'build/static/client.js', './client/main.coffee', config, cb

  writeConfig: (cb) ->
    Build.writeJson 'build/config.json', config
    cb?()

  deploy: (cb) ->
    sh """
      ssh root@#{config.deploy.server} <<END
      # Stop the old if it exists.
      supervisorctl stop #{config.name} 2>/dev/null
      END

      ssh #{config.deploy.user}@#{config.deploy.server} <<END
      # Create the install location or ignore.
      mkdir -p #{config.deploy.installPath} 2>/dev/null
      END

      # Rsync the new files.
      rsync -a --del build/ #{config.deploy.server}:#{config.deploy.installPath}/

      ssh root@#{config.deploy.server} <<END

      # Install the supervisor config file.
      cat > /etc/supervisor/conf.d/#{config.name}.conf <<END2
      #{config.deploy.supervisorScript}
      END2

      # Refresh supervisor config.
      supervisorctl reread
      supervisorctl update
      supervisorctl start #{config.name} 2>/dev/null

      END

    """, cb

  'remote-log': (cb) ->
    host = "#{config.deploy.user}@#{config.deploy.server}"
    cmd 'ssh', [host, 'tail', '-f', "/var/log/#{config.name}.out.log"], cb

b.makePublic
  init: 'Create `build` and import the requirements.'
  clean: 'Clean `build` except for the downloaded requirements.'
  npm: 'Update `package.json` and install needed requirements.'
  bower: 'Update `bower.json` and install needed requirements.'
  build: 'Build everything.'
  run: 'Run the node server locally.'
  deploy: 'Deploy to the remote server.'
  'remote-log': 'Follow log from remote host.'
