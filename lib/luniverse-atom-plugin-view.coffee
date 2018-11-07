{TextEditorView, View} = require 'atom-space-pen-views'

LuniverseApiClient = require './luniverse-api-client'

module.exports =
class LuniverseSignInView extends View

  @content: ->
    @div class: 'luniverse-signin-modal overlay from-top padded', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @span 'Sign in to Luniverse'
        @div class: 'panel-body padded', =>
          @div =>
            @subview 'emailField', new TextEditorView(mini:true, placeholderText: 'Enter Email Address')
            @subview 'passwordField', new TextEditorView(mini:true, placeholderText: 'Enter Password')
            @div class: 'pull-right', =>
              @br()
              @button outlet: 'askButton', class: 'btn btn-primary', ' Login '
            @div class: 'clearfix', =>
              @br()
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    @handleEvents()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @hideView()
    @detach()

  hideView: ->
    @panel.hide()
    @.focusout()

  onDidChangeTitle: ->
  onDidChangeModified: ->

  handleEvents: ->
    @askButton.on 'click', => @luniverseLoginRequest()

  presentPanel: ->
    console.log('presentPanel')
    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)

    @panel.show()
    @progressIndicator.hide()
    @emailField.focus()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  luniverseLoginRequest: ->
    @progressIndicator.show()

    LuniverseApiClient.login @emailField.getText(), @passwordField.getText(), (response) =>
      @progressIndicator.hide()
      this.hideView()
      if response.data.token
        atom.notifications.addSuccess('Luniverse 로그인 완료. Luniverse Api를 사용가능합니다.')
      else
        atom.notifications.addError('Luniverse 로그인 실패.')

  toggleFocus: ->
    if @emailField.element.hasFocus()
      @passwordField.focus()
    else
      @emailField.focus()
