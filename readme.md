# This repository has been moved to [gitlab.com/paul-nechifor/outline](http://gitlab.com/paul-nechifor/outline).

Old readme:

# Outline

A skeleton for Node, Express, CoffeeScript, Browserify, Bootstrap and
minification.

## Starting up

The project is written in CoffeeScript and you have to have `cake` to build it.
Install it:

    sudo npm install -g coffee-script

You also need bower:

    sudo npm install -g bower

Download the dependencies:

    npm install

Initialize the project:

    cake init

Build it:

    cake build

Start it locally:

    cake run

To deploy it fiddle with `config.deploy` in `config.coffee`. You might want to
put the changes in `secret.coffee`. Deploy to the server:

    cake deploy

To read the description of all the available tasks:

    cake

## Licence

MIT
