# solc = require 'solc'
url = require 'url'
fs = require 'fs'
shell = require 'shelljs'
path = require 'path'

LuniverseSignInView = require './luniverse-atom-plugin-view'
LuniverseCreateContractView = require './luniverse-create-contract-view'
LuniverseApiClient = require './luniverse-api-client'
LuniverseAuditListView = require './luniverse-audit-list-view'

{CompositeDisposable} = require 'event-kit'

module.exports =
  luniverseSignInView: null
  luniverseCreateContractView: null

  activate: (state) ->
    console.log("LuniverseSignInView state")
    console.log(state)

    LuniverseApiClient.setToken state.token
    @luniverseSignInView = new LuniverseSignInView(state.token)
    @luniverseCreateContractView = new LuniverseCreateContractView(state.token)

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:create-audit', => @createAudit()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:security-assessment-reports', => @checkSecurityAssessmentReports()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse:compile-contract', => @compileContract()

    # @subscriptions.add atom.commands.add 'atom-workspace',
    #   'luniverse:compile-contract', => @luniverseCreateContractView.presentPanel()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-signin:present-panel', => @luniverseSignInView.presentPanel()

    @subscriptions.add atom.commands.add @luniverseSignInView.element,
      'luniverse-signin:focus-next', => @luniverseSignInView.toggleFocus()

    @subscriptions.add atom.commands.add @luniverseSignInView.element,
      'luniverse:dismiss-panel', => @luniverseSignInView.dismissPanel()

    @subscriptions.add atom.commands.add @luniverseCreateContractView.element,
      'luniverse:dismiss-panel', => @luniverseCreateContractView.dismissPanel()

    @subscriptions.add atom.commands.add @luniverseSignInView.passwordField.element,
      'core:confirm': => @luniverseSignInView.luniverseLoginRequest()

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        console.log('error: ' + error)
        return

      console.log('protocol: ' + protocol)
      console.log('host: ' + host)
      console.log('pathname: ' + pathname)
      return unless protocol is 'luniverse:'

      if host is 'audit-list'
        return new LuniverseAuditListView()

      return

  deactivate: ->
    @luniverseSignInView.destroy()

  serialize: ->
    token: LuniverseApiClient.token

  createAudit: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor
      totalCode = editor.getText()
      LuniverseApiClient.securityAssessment 'Atom Request Code', 'code', totalCode, (response) =>
        console.log(response)
        if response == null
          atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다')
        else
          console.log('response is not null')
          atom.notifications.addSuccess('Luniverse Security Assessment 요청이 완료되었습니다!')
          @checkSecurityAssessmentReports()

  compileContract: ->
    # LuniverseApiClient.getChainList (response) ->
    #   console.log('getChainList response')
    #   console.log(response)
    editor = atom.workspace.getActiveTextEditor()
    # pane = atom.workspace.getActivePaneItem()
    # container = atom.workspace.getActivePaneContainer()
    # console.log(editor.getPath())
    # console.log('pane')
    # console.log(pane)
    # console.log('container')
    # console.log(container)
    #
    # filePath = atom.workspace.getActivePaneItem().buffer.file.path
    # projectPath = ""
    # atom.project.getDirectories().forEach (dir) =>
    #   if dir.contains filePath
    #     projectPath = dir.path
    # console.log(projectPath)
    projectPath = '/Users/mint/Desktop/Lambda256/lambda-token-protocol'
    # atom.notifications.addInfo('message message', {
    #   buttons: [
    #     {
    #       className: 'btn-details',
    #       onDidClick: ->,
    #       text: 'Details'
    #     }
    #   ],
    #   detail: 'This is more stuff'
    #   })

    console.log('start compiling')
    console.log(shell.which('node').stdout)
    shell.config.execPath = shell.which('node').stdout
    console.log(shell.cd(projectPath))
    # for contractJSON in shell.ls(projectPath + '/build/contracts')
    #   console.log(contractJSON)
    # console.log(shell.exec('git status'))
    # console.log(shell.exec('./node_modules/.bin/truffle compile'))
    compileResult = shell.exec 'truffle compile'
    if compileResult.code is 0
      console.log('truffle compile success')
      console.log(compileResult)
      truffleNotification = atom.notifications.addSuccess('truffle compile success', {
        buttons: [
          {
            className: 'btn-details',
            onDidClick: =>
              @deployContract()
              truffleNotification.dismiss()
            ,
            text: 'Deploy through Luniverse'
          }
        ],
        detail: compileResult.stdout,
        dismissable: true
        })

    # console.log(shell.exec('truffle compile'))

    # console.log('dirname: ' + __dirname)
    # console.log('process.cwd(): ' + process.cwd())

    # input = {
    #   'cont.sol': 'import "lib.sol"; contract x { function g() { L.f(); } }',
    #   'lib.sol': 'library L { function f() returns (uint) { return 7; } }'
    # }
    # output = solc.compile({ sources: input }, 1)
    # for contractName of output.contracts
    #   console.log(contractName + ': ' + output.contracts[contractName].bytecode)
    #
    # data = fs.readFileSync('/Users/mint/Desktop/Lambda256/solidity_example.sol')
    # console.log(data.toString())

    # fs.readFile '/Users/mint/Desktop/Lambda256/solidity_example.sol', (err, data) =>
    #   console.log 'Asynchronous read: ' + data.toString()
    # if editor
    #   totalCode = editor.getText()
    #   input = totalCode
    #   output = solc.compile(input, 1)
    #   console.log(output)
    #   for contractName of output.contracts
    #     bytecode = output.contracts[contractName].bytecode
    #     abi = JSON.parse(output.contracts[contractName].interface)
    #     params = [{name: '_helloKorean', type: 'string', val: 'helloK'}, {name: '_helloEnglish', type: 'string', val: 'helloE'}]
    #     console.log(contractName + ': ' + bytecode)
    #     console.log(abi)
    #     console.log(params)
    #     @luniverseCreateContractView.presentPanel abi, bytecode
        # LuniverseApiClient.createContract 'contractName', 'contractDescription', abi, bytecode, params, (response) =>
        #   console.log('createContract response')
        #   console.log(response)

  deployContract: ->
    console.log('deployContract')
    projectPath = '/Users/mint/Desktop/Lambda256/lambda-token-protocol'
    @luniverseCreateContractView.presentPanel shell.ls(projectPath + '/build/contracts')

  checkSecurityAssessmentReports: ->
    console.log('checkSecurityAssessmentReports')
    LuniverseApiClient.securityAssessmentReports 1, (response) =>
      console.log(response)
      @showResults response.data.reports

  showResults: (reportsJson) ->
    uri = 'luniverse://audit-list'
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).then (luniverseAuditListView) ->
      console.log('luniverseAuditListView')
      console.log(luniverseAuditListView)
      if luniverseAuditListView instanceof LuniverseAuditListView
        console.log('renderReports')
        luniverseAuditListView.renderReports(reportsJson)
        atom.workspace.activatePreviousPane()
