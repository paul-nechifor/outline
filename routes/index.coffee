module.exports = (app) ->

  exports.index = (req, res) ->
    res.render 'index', {title: 'Outline'}

  return exports
