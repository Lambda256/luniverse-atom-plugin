LuniverseSignInView = require './luniverse-atom-plugin-view'
LuniverseApiClient = require './luniverse-api-client'

{CompositeDisposable} = require 'event-kit'

module.exports =
  luniverseSignInView: null

  activate: (state) ->
    console.log("LuniverseSignInView state")
    console.log(state)

    LuniverseApiClient.setToken state.token
    @luniverseSignInView = new LuniverseSignInView(state.token)

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:create-audit', => @createAudit()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-signin:present-panel', => @luniverseSignInView.presentPanel()

    @subscriptions.add atom.commands.add @luniverseSignInView.element,
      'luniverse-signin:focus-next', => @luniverseSignInView.toggleFocus()

    @subscriptions.add atom.commands.add @luniverseSignInView.element,
      'luniverse-signin:dismiss-panel', => @luniverseSignInView.dismissPanel()

    @subscriptions.add atom.commands.add @luniverseSignInView.passwordField.element,
      'core:confirm': => @luniverseSignInView.luniverseLoginRequest()

  deactivate: ->
    @luniverseSignInView.destroy()

  serialize: ->
    token: LuniverseApiClient.token

  createAudit: ->
    console.log('createAudit')
    editor = atom.workspace.getActiveTextEditor()
    if editor
      console.log('active editor exist')
      totalCode = editor.getText()
      LuniverseApiClient.securityAssessment 'contractName 3', 'code', totalCode, (response) ->
        console.log(response)
        if response == null
          atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다')
        else
          console.log('response is not null')
          atom.notifications.addSuccess('Luniverse Security Assessment 요청이 완료되었습니다!')
