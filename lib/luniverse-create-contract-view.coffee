{$, $$, $$$, TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs'

LuniverseApiClient = require './luniverse-api-client'

module.exports =
class LuniverseCreateContractView extends View

  compiledObject: null
  parameterFields: []

  @content: ->
    @div class: 'luniverse-create-contract-modal overlay from-top padded', =>
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
      chainId = @chainSelector.val()
      name = @compiledObject.contractName
      description = 'description example'
      abi = @compiledObject.abi
      bytecode = @compiledObject.bytecode
      params = []

      @parameterFields.forEach (paramField) ->
        params.push {name: paramField.inputInfo.name, type: paramField.inputInfo.type, val: paramField.getText()}

      LuniverseApiClient.createContract chainId, name, description, abi, bytecode, params, (response) =>
        console.log('createContract response')
        console.log(response)
        if response.code is 'OK'
          @dismissPanel()
          atom.notifications.addSuccess('Contract Deploy 요청이 완료되었습니다!')

      # @constructorParameters.context.childNodes.forEach (paramField) ->
      #   console.log(paramField)
      #   console.log(paramField.__spacePenView)
      # @constructorParameters.forEach (elem) ->
      #   console.log('createContract forEach')
      #   console.log(elem)
      # @createContract()
    @contractSelector.on 'change', (e) =>
      console.log($(e.target).val())
      projectPath = '/Users/mint/Desktop/Lambda256/lambda-token-protocol'
      @setConstructorParameters(projectPath + '/build/contracts/', $(e.target).val())

  presentPanel: (contractBuildArray) ->
    console.log('presentPanel')

    # pencil =

    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)

    @panel.show()
    @progressIndicator.show()

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



  # presentSingleContractPanel: (abi, bytecode) ->
  #   console.log('presentPanel')
  #
  #   @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
  #
  #   @panel.show()
  #   @progressIndicator.show()
  #
  #   parsedABI = @parseABI abi
  #   console.log('inputs')
  #   console.log(parsedABI)
  #
  #   @constructorParameters.empty()
  #   parsedABI.forEach (elem) =>
  #     @constructorParameters.append new TextEditorView(mini:true, placeholderText: 'Enter ' + elem.name + '(' + elem.type + ') value.')
  #
  #   LuniverseApiClient.getChainList (response) =>
  #     console.log('getChainList response')
  #     console.log(response)
  #     if response == null
  #       atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다')
  #     else
  #       console.log('response is not null')
  #       @chainSelector.empty()
  #       for chain in response.data.chains
  #         @chainSelector.append new Option(chain.name, chain.chainId)
  #       @chainSelector.focus()
  #     @progressIndicator.hide()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  setConstructorParameters: (targetPath, targetContract) ->
    console.log('targetPath: ' + targetPath)
    console.log('targetContract: ' + targetContract)
    data = JSON.parse(fs.readFileSync(targetPath + targetContract))
    console.log(data.abi)
    console.log(data.bytecode)

    @compiledObject = data

    parsedABI = @parseABI data.abi
    @constructorParameters.empty()
    @parameterFields = []
    parsedABI.forEach (elem) =>
      textEditor = new TextEditorView(mini:true, placeholderText: 'Enter ' + elem.name + '(' + elem.type + ') value.')
      textEditor.inputInfo = elem
      @parameterFields.push textEditor
      @constructorParameters.append textEditor

  createContract: ->
    console.log(@chainSelector.val())
    console.log(@contractSelector.val())
    @constructorInputs.forEach (elem) ->
      console.log('createContract forEach')
      console.log(elem)
    @dismissPanel()

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
