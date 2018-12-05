{$, TextEditorView, View, ScrollView} = require 'atom-space-pen-views'
fs = require 'fs'

helper = require './luniverse-helper-functions'
LuniverseApiClient = require './luniverse-api-client'

# <aside class="layout-atom layout-popup">
#   <h1 class="layout-atom-title">Create User Contract</h1>
#
#   <fieldset class="forms">
#     <legend>create user contract</legend>
#
#     <div class="form-section">
#       <label for="">Name</label>
#       <input type="text" id="" placeholder="Enter Contract Name">
#
#
#       <label for="">Description (Optional)</label>
#       <input type="text" id="" placeholder="Enter Description">
#     </div>
#
#
#     <div class="form-section">
#       <label for="upload-file">Contract File</label>
#
#       <div class="uploads">
#         <input type="file" id="upload">
#         <label for="upload" class="button-normal">
#           <i class="fa fa-upload"></i>
#           Upload Contract
#         </label>
#
#         <span class="filename">Uploadfile.sol</span>
#         <button type="button" class="btn-close">
#           <i class="fa fa-close"></i>
#           <span class="hidden">delete</span>
#         </button>
#       </div>
#     </div>
#
#
#     <div class="form-section">
#       <label for="">
#         Security Assessment
#         <i class="icon-info"></i>
# <!-- 					<span class="i i2">
#                   <span class="ly_tooltip">Security Assessment Security Assessment Security Assessment..tooltip</span>
#                   </span>
# -->				</label>
#
#
#       <div class="right-utils">
#         <a href="#" class="button-normal">
#           <i class="fa fa-code-fork"></i>
#           Security Assessment
#         </a>
#       </div>
#
#       <table class="tbl-security-level">
#         <caption>Security Level</caption>
#         <tbody>
#           <tr>
#             <th rowspan="2" class="security-level level-c">
#               <strong>C</strong>
#               <span>Security Level</span>
#             </th>
#             <th>Critical</th>
#             <th>High</th>
#             <th>Medium</th>
#             <th>Low</th>
#             <th>Notie</th>
#           </tr>
#           <tr>
#             <td>0</td>
#             <td>0</td>
#             <td>0</td>
#             <td>0</td>
#             <td>1</td>
#           </tr>
#         </tbody>
#       </table>
#     </div>
#
#
#     <div class="form-section">
#       <label for="">Contract Select</label>
#       <select name="" id="">
#         <option value="">Select Contract</option>
#         <option value="">Contract 1</option>
#         <option value="">Contract 2</option>
#         <option value="">Contract 3</option>
#         <option value="">Contract 4</option>
#         <option value="">Contract 5</option>
#       </select>
#
#       <label for="">Contract Select</label>
#       <table class="tbl-form-vertical">
#                   <colgroup>
#                       <col style="width: 150px">
#                       <col style="width: 150px">
#                       <col>
#                   </colgroup>
#                   <thead>
#                       <tr>
#                           <th scope="col">Name</th>
#                           <th scope="col">Type</th>
#                           <th scope="col">Value</th>
#                       </tr>
#                   </thead>
#                   <tbody>
#                       <tr>
#                           <td><input type="text" id="" disabled value="Token Name"></td>
#                           <td><input type="text" id="" disabled value="String"></td>
#                           <td><input type="text" id="" value="Token"></td>
#                       </tr>
#                       <tr>
#                           <td><input type="text" id="" disabled value="Decimal Units"></td>
#                           <td><input type="text" id="" disabled value="Unit8"></td>
#                           <td><input type="text" id="" value="32"></td>
#                       </tr>
#                   </tbody>
#               </table>
#
#
#       <label for="">Function Description (Optional)</label>
#       <input type="text" id="" placeholder="Enter Function Description">
#     </div>
#
#
#     <div class="btns">
#       <button type="button" class="button-cancel">Cancel</button>
#       <button type="submit" class="button-submit">Apply</button>
#     </div>
#   </fieldset>
# </aside>


# <table class="tbl-form-vertical">
#   <colgroup>
#       <col style="width: 150px">
#       <col style="width: 150px">
#       <col>
#   </colgroup>
#   <thead>
#       <tr>
#           <th scope="col">Name</th>
#           <th scope="col">Type</th>
#           <th scope="col">Value</th>
#       </tr>
#   </thead>
#   <tbody>
#       <tr>
#           <td><input type="text" id="" disabled value="Token Name"></td>
#           <td><input type="text" id="" disabled value="String"></td>
#           <td><input type="text" id="" value="Token"></td>
#       </tr>
#       <tr>
#           <td><input type="text" id="" disabled value="Decimal Units"></td>
#           <td><input type="text" id="" disabled value="Unit8"></td>
#           <td><input type="text" id="" value="32"></td>
#       </tr>
#   </tbody>
# </table>

module.exports =
class LuniverseCreateContractView extends View

  compiledObject: null
  parameterFields: []

  @content: ->
    @aside class: 'layout-atom-popup layout-popup native-key-bindings', =>
      @h1 class: 'layout-atom-title', 'Create User Contract'
      @fieldset class: 'forms', =>
        @legend 'create user contract'
        @div class: 'form-section', =>
          @label for: '', 'Name'
          @input type: 'text', id: '', placeholder: 'Enter Contract Name'
          # @subview 'nameField', new TextEditorView(mini: true, placeholderText: 'Enter Contract Name')
          @label for: '', 'Description (Optional)'
          @input type: 'text', id: '', placeholder: 'Enter Description'
          # @subview 'descriptionField', new TextEditorView(mini: true, placeholderText: 'Enter Description')
        @div class: 'form-section', =>
          @label for: '', 'Chain Select'
          @select outlet: 'chainSelector'
          @label for: '', 'Contract Select'
          @select outlet: 'contractSelector'
          @table class: 'tbl-form-vertical', =>
            @colgroup =>
              @col style: 'width: 150px'
              @col style: 'width: 150px'
              @col style: ''
            @thead =>
              @tr =>
                @th scope: 'col', 'Name'
                @th scope: 'col', 'Type'
                @th scope: 'col', 'Value'
            @tbody =>
              @tr =>
                @td =>
                  @input type: 'text', id: '', disabled: 'true', value: 'Token Name'
                @td =>
                  @input type: 'text', id: '', disabled: 'true', value: 'String'
                @td =>
                  @input type: 'text', id: '', value: ''
                  # @subview 'parameterField', new TextEditorView(mini: true, placeholderText: 'Enter Parameter')
          @label for: '', 'Function Description (Optional)'
          @input type: 'text', id: '', placeholder: 'Enter Function Description'
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
      name = @compiledObject.contractName
      description = 'description example'
      abi = @compiledObject.abi
      bytecode = @compiledObject.bytecode
      params = []

      @parameterFields.forEach (paramField) ->
        params.push {name: paramField.inputInfo.name, type: paramField.inputInfo.type, val: paramField.getText()}

      LuniverseApiClient.createContract chainId, name, description, abi, bytecode, params
        .then (res) ->
          if res.code is 'OK'
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

    @contractSelector.on 'change', (e) =>
      console.log($(e.target).val())
      projectPath = helper.getUserPath()
      @setConstructorParameters(projectPath + '/build/contracts/', $(e.target).val())

  # presentPanel: (result)

  presentPanel: (contractBuildArray) ->
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
        @initializeSelectBox @chainSelector, 'Select your Luniverse-Chain'
        if res.result
          for chain in res.data.chains
            @chainSelector.append new Option(chain.name, chain.chainId)
          @chainSelector.focus()
        else
          throw new Error(res.message)
      .catch (error) ->
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
          detail: error.message,
          dismissable: true
        })
      .then =>
        @progressIndicator.hide()

  dismissPanel: ->
    console.log('dismissPanel')
    this.hideView()

  setConstructorParameters: (targetPath, targetContract) ->
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

  initializeSelectBox: (selectBox, defaultText) ->
    selectBox.empty()
    defaultOption = new Option(defaultText)
    defaultOption.disabled = true
    defaultOption.selected = true
    selectBox.append defaultOption
