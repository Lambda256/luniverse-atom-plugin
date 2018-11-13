{TextEditorView, View} = require 'atom-space-pen-views'

LuniverseApiClient = require './luniverse-api-client'

module.exports =
class LuniverseCreateContractView extends View

  @content: ->
    @div class: 'luniverse-create-contract-modal overlay from-top padded', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @span 'Select Your Chain'
        @div class: 'panel-body padded', =>
          @div =>
            @select outlet: 'chainSelector', class: 'form-control'
            @div outlet: 'constructorParameters', =>
              @span 'Constructor Parameter'
            @div class: 'pull-right', =>
              @br()
              @button outlet: 'createButton', class: 'btn btn-primary', ' Create '
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

  presentPanel: (abi, bytecode) ->
    console.log('presentPanel')

    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)

    @panel.show()
    @progressIndicator.show()

    parsedABI = @parseABI abi
    console.log('inputs')
    console.log(parsedABI)

    parsedABI.forEach (elem) =>
      @constructorParameters.append new TextEditorView(mini:true, placeholderText: 'Enter ' + elem.name + '(' + elem.type + ') value.')
    LuniverseApiClient.getChainList (response) =>
      console.log('getChainList response')
      console.log(response)
      if response == null
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다')
      else
        console.log('response is not null')
        @chainSelector.empty()
        for chain in response.data.chains
          @chainSelector.append new Option(chain.name, chain.chainId)
        @chainSelector.focus()
      @progressIndicator.hide()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  parseABI: (abi) ->
    # return type is array
    [constructorInputs, ...] = abi.filter ((elem) ->
      return elem.type is 'constructor')
      .map ((elem) ->
        return elem.inputs)

    if constructorInputs
      return constructorInputs
    return []
