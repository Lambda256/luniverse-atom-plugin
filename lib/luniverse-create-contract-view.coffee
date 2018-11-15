{$, TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs'

helper = require './luniverse-helper-functions'
LuniverseApiClient = require './luniverse-api-client'

module.exports =
class LuniverseCreateContractView extends View

  compiledObject: null
  parameterFields: []

  @content: ->
    @div class: 'luniverse-modal overlay from-top padded', =>
      @div class: 'inset-panel', =>
        @div class: 'panel-heading', =>
          @span 'Select Your Chain'
        @div class: 'panel-body padded', =>
          @div =>
            @select outlet: 'chainSelector', class: 'form-control'
            @select outlet: 'contractSelector', class: 'form-control'
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
    @createButton.on 'click', =>
      @progressIndicator.show()

      chainId = @chainSelector.val()
      name = @compiledObject.contractName
      description = 'description example'
      abi = @compiledObject.abi
      bytecode = @compiledObject.bytecode
      params = []

      @parameterFields.forEach (paramField) ->
        params.push {name: paramField.inputInfo.name, type: paramField.inputInfo.type, val: paramField.getText()}

      LuniverseApiClient.createContract chainId, name, description, abi, bytecode, params, (response) =>
        console.log(response)
        if response.code is 'OK'
          @dismissPanel()
          atom.notifications.addSuccess('Contract Deploy 요청이 완료되었습니다!')

    @contractSelector.on 'change', (e) =>
      console.log($(e.target).val())
      projectPath = helper.getUserPath()
      @setConstructorParameters(projectPath + '/build/contracts/', $(e.target).val())

  presentPanel: (contractBuildArray) ->
    @compiledObject = null
    @parameterFields = []

    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
    @panel.show()
    @progressIndicator.show()

    @chainSelector.focus()

    @initializeSelectBox @contractSelector, 'Select your compiled contract file'

    @constructorParameters.empty()

    contractBuildArray.forEach ((json) =>
      @contractSelector.append new Option(json, json)
      )

    LuniverseApiClient.getChainList (response) =>
      console.log('getChainList response')
      console.log(response)
      if response == null
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다')
      else
        console.log('response is not null')
        @initializeSelectBox @chainSelector, 'Select your Luniverse-Chain'
        for chain in response.data.chains
          @chainSelector.append new Option(chain.name, chain.chainId)
        @chainSelector.focus()
      @progressIndicator.hide()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  setConstructorParameters: (targetPath, targetContract) ->
    data = JSON.parse(fs.readFileSync(targetPath + targetContract))

    @compiledObject = data

    parsedABI = @parseABI data.abi
    @constructorParameters.empty()
    @parameterFields = []
    parsedABI.forEach (elem) =>
      textEditor = new TextEditorView(mini:true, placeholderText: 'Enter ' + elem.name + '(' + elem.type + ') value.')
      textEditor.inputInfo = elem
      @parameterFields.push textEditor
      @constructorParameters.append textEditor

  toggleFocus: ->
    for inputField, index in @parameterFields
      if inputField.element.hasFocus() && index + 1 < @parameterFields.length
        @parameterFields[index + 1].focus()
        return



  parseABI: (abi) -> # returns [Object]
    [constructorInputs, ...] = abi.filter ((elem) ->
      return elem.type is 'constructor')
      .map ((elem) ->
        return elem.inputs)

    if constructorInputs
      return constructorInputs
    return []

  initializeSelectBox: (selectBox, defaultText) ->
    selectBox.empty()
    defaultOption = new Option(defaultText)
    defaultOption.disabled = true
    defaultOption.selected = true
    selectBox.append defaultOption
