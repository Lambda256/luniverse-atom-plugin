LuniverseSignInView = require './luniverse-atom-plugin-view'

module.exports =
  luniverseSignInView: null
  token: null

  activate: (state) ->
    console.log("LuniverseSignInView state")
    console.log(state)
    @luniverseSignInView = new LuniverseSignInView(state.token)

  deactivate: ->
    @luniverseSignInView.destroy()

  serialize: ->
    token: @luniverseSignInView.token
