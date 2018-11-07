{CompositeDisposable} = require 'event-kit'
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

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-signin:present-panel', => @presentPanel()

    @subscriptions.add atom.commands.add this.element,
      'luniverse-signin:focus-next', => @toggleFocus()

    @subscriptions.add atom.commands.add this.element,
      'luniverse-signin:dismiss-panel', => @dismissPanel()

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

    @subscriptions.add atom.commands.add @emailField,
      'core:confirm': => @luniverseLoginRequest()
      'core:cancel': => @hideView()

    @subscriptions.add atom.commands.add @passwordField,
      'core:confirm': => @luniverseLoginRequest()
      'core:cancel': => @hideView()

  presentPanel: ->
    console.log('presentPanel')
    #atom.workspaceView.append(this)
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
      if response == null
        alert('Luniverse API 통신 중 오류가 발생했습니다')
      else
        # @showResults(response)
        this.token = response.data.token
        console.log(this.token)

  toggleFocus: ->
    if @emailField.element.hasFocus()
      @passwordField.focus()
    else
      @emailField.focus()
