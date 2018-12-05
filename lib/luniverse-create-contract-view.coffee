{$, $$$, TextEditorView, View, ScrollView} = require 'atom-space-pen-views'
fs = require 'fs'

helper = require './luniverse-helper-functions'
LuniverseApiClient = require './luniverse-api-client'

module.exports =
class LuniverseCreateContractView extends View

  compiledObject: null
  parameterFields: []
  contracts: null
  paramaterObjects: []
  contractData: null

  @content: ->
    @aside class: 'layout-atom-popup layout-popup native-key-bindings', =>
      @h1 class: 'layout-atom-title', 'Create User Contract'
      @fieldset class: 'forms', =>
        @legend 'create user contract'
        @div class: 'form-section', =>
          @label for: '', 'Name'
          @input outlet: 'nameField', type: 'text', id: '', placeholder: 'Enter Contract Name'
          # @subview 'nameField', new TextEditorView(mini: true, placeholderText: 'Enter Contract Name')
          @label for: '', 'Description (Optional)'
          @input outlet: 'descriptionField', type: 'text', id: '', placeholder: 'Enter Description'
          # @subview 'descriptionField', new TextEditorView(mini: true, placeholderText: 'Enter Description')
        @div class: 'form-section', =>
          @label for: '', 'Chain Select'
          @select outlet: 'chainSelector'
          @label for: '', 'Contract Select'
          @select outlet: 'contractSelector'
          @label outlet: 'constructorLabel', for: '', 'Constructor Parameters'
          @table outlet: 'constructorTable', class: 'tbl-form-vertical', =>
            @colgroup =>
              @col style: 'width: 150px'
              @col style: 'width: 150px'
              @col style: ''
            @thead =>
              @tr =>
                @th scope: 'col', 'Name'
                @th scope: 'col', 'Type'
                @th scope: 'col', 'Value'
            @tbody outlet: 'constructorParameters'
          # @label for: '', 'Function Description (Optional)'
          # @input type: 'text', id: '', placeholder: 'Enter Function Description'
          # @subview 'functionDescriptionField', new TextEditorView(mini: true, placeholderText: 'Enter Function Description')
        @div class: 'btns', =>
          @button outlet: 'cancelButton', type: 'button', class: 'button-cancel', 'Cancel'
          @button outlet: 'createButton', type: 'submit', class: 'button-submit', 'Apply'
        @div outlet: 'progressIndicator', =>
          @span class: 'loading loading-spinner-medium'
    # @div class: 'luniverse-modal overlay from-top padded', =>
    #   @div class: 'inset-panel', =>
    #     @div class: 'panel-heading', =>
    #       @span 'Select Your Chain'
    #     @div class: 'panel-body padded', =>
    #       @div =>
    #         @select outlet: 'chainSelector', class: 'form-control'
    #         @select outlet: 'contractSelector', class: 'form-control'
    #         @div outlet: 'constructorParameters', =>
    #           @span 'Constructor Parameter'
    #         @div class: 'pull-right', =>
    #           @br()
    #           @button outlet: 'createButton', class: 'btn btn-primary', ' Create '
    #         @div class: 'clearfix', =>
    #           @br()
    #       @div outlet: 'progressIndicator', =>
    #         @span class: 'loading loading-spinner-medium'

  initialize: (serializeState) ->
    @hideConstructorParameters()
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
    @cancelButton.on 'click', =>
      this.hideView()

    @createButton.on 'click', =>
      @progressIndicator.show()

      chainId = @chainSelector.val()
      contractName = @contractSelector.val()
      name = @nameField.val()
      description = @descriptionField.val()
      contractFileId = @contractData.contractFile.contractFileId
      params = []

      parsedABI = @parseABI @contracts[contractName].abi
      parsedABI.forEach (elem) =>
        params.push {name: elem.name, type: elem.type, val: $('#' + elem.name).val()}

      LuniverseApiClient.requestDeploy chainId, name, description, contractFileId, contractName, params
        .then (res) ->
          if res.result && res.code is 'OK'
            atom.notifications.addSuccess('Contract Deploy 요청이 완료되었습니다!')
          else
            throw new Error(res.message)
        .catch (res) ->
          atom.notifications.addError('Contract Deploy가 실패했습니다.', {
            detail: error.message,
            dismissable: true
          })
        .then (res) =>
          @dismissPanel()

      # @parameterFields.forEach (paramField) ->
      #   params.push {name: paramField.inputInfo.name, type: paramField.inputInfo.type, val: paramField.getText()}

      # LuniverseApiClient.createContract chainId, name, description, abi, bytecode, params
      #   .then (res) ->
      #     if res.code is 'OK'
      #       atom.notifications.addSuccess('Contract Deploy 요청이 완료되었습니다!')
      #     else
      #       throw new Error(res.message)
      #   .catch (res) ->
      #     atom.notifications.addError('Contract Deploy가 실패했습니다.', {
      #       detail: error.message,
      #       dismissable: true
      #     })
      #   .then (res) =>
      #     @dismissPanel()

    @contractSelector.on 'change', (e) =>
      console.log('selector onchange')
      console.log($(e.target).val())
      @setConstructorParameters @contracts[$(e.target).val()].abi

      # console.log($(e.target).val())
      # projectPath = helper.getUserPath()
      # @setConstructorParameters(projectPath + '/build/contracts/', $(e.target).val())

  presentPanel: (data) ->
    console.log('presentPanel')
    console.log(data)
    @contractData = data
    @contracts = data.contractFile.contracts

    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
    @panel.show()
    @progressIndicator.show()

    @initializeSelectBox @contractSelector, 'Select your compiled contract file'
    Object.keys(data.contractFile.contracts).forEach (key) =>
      console.log(key, data.contractFile.contracts[key])
      @contractSelector.append new Option(key, key)

    LuniverseApiClient.getChainList()
      .then (res) =>
        console.log('chains')
        console.log(res)
        @initializeSelectBox @chainSelector, 'Select your Luniverse-Chain'
        if res.result
          for chain in res.data.chains
            @chainSelector.append new Option(chain.name, chain.chainId)
          @chainSelector.focus()
        else
          throw new Error(res.message)
      .catch (error) ->
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다2', {
          detail: error.message,
          dismissable: true
        })
      .then =>
        @progressIndicator.hide()


  presentPanel2: (contractBuildArray) ->
    @compiledObject = null
    @parameterFields = []

    @panel ?= atom.workspace.addModalPanel(item: @, visible: true)
    @panel.show()
    @progressIndicator.show()

    @chainSelector.focus()

    @initializeSelectBox @contractSelector, 'Select your compiled contract file'

    # @constructorParameters.empty()

    contractBuildArray.forEach ((json) =>
      @contractSelector.append new Option(json, json)
      )

    LuniverseApiClient.getChainList()
      .then (res) =>
        console.log('chains')
        console.log(res)
        @initializeSelectBox @chainSelector, 'Select your Luniverse-Chain'
        if res.result
          for chain in res.data.chains
            @chainSelector.append new Option(chain.name, chain.chainId)
          @chainSelector.focus()
        else
          throw new Error(res.message)
      .catch (error) ->
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다3', {
          detail: error.message,
          dismissable: true
        })
      .then =>
        @progressIndicator.hide()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  setConstructorParameters: (abi) ->
    @constructorParameters.empty()
    parsedABI = @parseABI abi
    if parsedABI.length > 0
      @showConstructorParameters()
    else
      @hideConstructorParameters()
    parsedABI.forEach (elem) =>
      row = $$$ ->
        @tr =>
          @td =>
            @input type: 'text', id: '', disabled: 'true', value: elem.name
          @td =>
            @input type: 'text', id: '', disabled: 'true', value: elem.type
          @td =>
            @input type: 'text', id: elem.name, value: ''
      @constructorParameters.append row
      # textEditor = new TextEditorView(mini:true, placeholderText: 'Enter ' + elem.name + '(' + elem.type + ') value.')
      # textEditor.inputInfo = elem
      # @parameterFields.push textEditor
      # @constructorParameters.append textEditor

  setConstructorParameters2: (targetPath, targetContract) ->
    data = JSON.parse(fs.readFileSync(targetPath + targetContract))

    @compiledObject = data

    parsedABI = @parseABI data.abi
    # @constructorParameters.empty()
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

  hideConstructorParameters: ->
    @constructorLabel.hide()
    @constructorTable.hide()

  showConstructorParameters: ->
    @constructorLabel.show()
    @constructorTable.show()

  initializeSelectBox: (selectBox, defaultText) ->
    selectBox.empty()
    defaultOption = new Option(defaultText)
    defaultOption.disabled = true
    defaultOption.selected = true
    selectBox.append defaultOption
