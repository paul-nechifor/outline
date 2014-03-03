# Outline

A skeleton for Node, Express, CoffeeScript, Browserify, Bootstrap and
minification.

## Starting up

The project is written in CoffeeScript and you have to have `cake` to build it.
Install it:

    npm install -g coffee-script

To read the description of all the available tasks:

    cake

Initialize the project:

    cake init

Build it:

    cake build

Start it locally:

    cake run

To deploy it fiddle with `config.deploy` in `config.coffee`. You might want to
put the changes in `secret.coffee`. Deploy to the server:

    cake deploy

## Licence

MIT
