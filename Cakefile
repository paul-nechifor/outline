fs = require 'fs'
{exec, spawn} = require 'child_process'

require('coffee-script').register()

config = require './config.coffee'

requireMaybe = (dir) ->
  return if not fs.existsSync(dir)
  return require dir

browserify = requireMaybe './build/node_modules/browserify'
coffeeify = requireMaybe './build/node_modules/coffeeify'
uglifyJs = requireMaybe './build/node_modules/uglify-js'
stylus = requireMaybe './build/node_modules/stylus'

shell = (commands, cb) ->
  exec commands, (err, stdout, stderr) ->
    throw err if err
    out = stdout + stderr
    console.log out if out.length > 0
    cb()

command = (name, args, cb) ->
  p = spawn name, args
  p.stdout.on 'data', (data) -> console.log data + ''
  p.stderr.on 'data', (data) -> console.log data + ''
  p.on 'close', cb

processOptions = (options) ->
  if options.minify
    config.minify = true

task_ = (cmd, desc, func) ->
  task cmd, desc, (options) ->
    processOptions options
    func()

compileStylus = (inFile, outFile, cb) ->
  input = fs.readFileSync(inFile).toString()
  s = stylus input
  s.set 'compress', true
  s.render (err, css) ->
    throw err if err
    fs.writeFileSync outFile, css
    cb()


actions =
  run: (names, cb) ->
    i = 0
    next = ->
      actions[names[i]] ->
        i++
        return cb?() if i >= names.length
        next()
    next()

  makeBuild: (cb) ->
    return cb() if fs.existsSync 'build'
    shell 'mkdir build', cb

  reset: (cb) ->
    keep =
      'bower_components': true
      'node_modules': true
    actions.makeBuild ->
      subs = fs.readdirSync('build')
      subs = ('build/' + f for f in subs when not keep[f])
      return cb() if subs.length == 0
      subs.splice 0, 0, '-rf'
      command 'rm', subs, cb

  bower: (cb) ->
    fs.writeFileSync 'build/bower.json', JSON.stringify(config.bower)
    shell 'cd build; bower install', cb

  npm: (cb) ->
    fs.writeFileSync 'build/package.json', JSON.stringify(config.packageJson)
    shell 'cd build; npm install', cb

  runServer: (cb) ->
    command 'node', ['build/app/main.js'], cb

  app: (cb) ->
    actions.run ['compileApp', 'compileRoutes', 'copyFiles', 'compileStylus',
                 'commandify', 'browserify', 'writeConfig']

  copyFiles: (cb) ->
    shell """
      mkdir -p build/static/b/css build/static/b/js >/dev/null 2>/dev/null
      cp -r static/ build/
      cp -r views build/views
      cd build/bower_components/bootstrap/dist
      cp -r fonts ../../../static/b
      cp css/bootstrap.min.css ../../../static/b/css
      cp js/bootstrap.min.js ../../../static/b/js
    """, cb

  compileApp: (cb) ->
    shell 'coffee --compile --bare --output build/app app', cb

  compileRoutes: (cb) ->
    shell 'coffee --compile --bare --output build/routes routes', cb

  compileStylus: (cb) ->
    compileStylus 'styles/main.styl', 'build/static/main.css', cb

  commandify: (cb) ->
    cmd = 'build/app/main.js'
    main = fs.readFileSync cmd
    fs.writeFileSync cmd, '#!/usr/bin/env node\n\n' + main
    shell 'chmod +x ' + cmd, cb

  browserify: (cb) ->
    b = browserify()
    b.add './client/main.coffee'
    b.transform coffeeify
    b.bundle
      debug: true
      transform: coffeeify
    , (err, result) ->
      throw err if err
      if config.minify
        done = uglifyJs.minify result, {fromString: true}
        fs.writeFileSync 'build/static/client.js', done.code
      else
        fs.writeFileSync 'build/static/client.js', result
      cb()

  writeConfig: (cb) ->
    fs.writeFileSync 'build/config.json', JSON.stringify(config)

  deploy: (cb) ->
    shell """
      ssh root@#{config.deploy.server} <<END
      # Stop the old if it exists.
      supervisorctl stop #{config.name}
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
      supervisorctl start #{config.name}

      END

    """, cb

  remoteLog: (cb) ->
    host = config.deploy.user + '@' + config.deploy.server
    host = "#{config.deploy.user}@#{config.deploy.server}"

    command 'ssh', [host, 'tail', '-f', "/var/log/#{config.name}.out.log"], cb

option '-m', '--minify', 'minify the client'

task 'init', 'Create `build` and import the requirements.', ->
  actions.run ['reset', 'npm', 'bower']

task 'reset', 'Clean `build` except for the downloaded requirements.', ->
  actions.reset ->

task 'bower', 'Update `bower.json` and install needed requirements.', ->
  actions.bower ->

task 'npm', 'Update `package.json` and install needed requirements.', ->
  actions.npm ->

task_ 'build', 'Build the server app.', ->
  actions.run ['reset', 'app']

task 'run', 'Run the node server locally.', ->
  actions.runServer ->

task 'deploy', 'Deploy to the remote server.', ->
  actions.deploy ->

task 'remote-log', 'Follow log from remote host.', ->
  actions.remoteLog ->
