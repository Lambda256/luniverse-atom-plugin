# solc = require 'solc'
url = require 'url'
shell = require 'shelljs'

helper = require './luniverse-helper-functions'
LuniverseCreateContractView = require './luniverse-create-contract-view'
LuniverseApiClient = require './luniverse-api-client'
LuniverseAuditListView = require './luniverse-audit-list-view'

{CompositeDisposable} = require 'event-kit'

module.exports =
  luniverseCreateContractView: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    # If email changed -> signin again
    @subscriptions.add atom.config.onDidChange "luniverse-atom-plugin.accountEmail", ({ newEmail }) =>
      @signInLuniverse newEmail, atom.config.get('luniverse-atom-plugin.accountPassword')

    # If password changed -> signin again
    @subscriptions.add atom.config.onDidChange "luniverse-atom-plugin.accountPassword", ({ newPassword }) =>
      @signInLuniverse atom.config.get('luniverse-atom-plugin.accountEmail'), newPassword

    @signInLuniverse atom.config.get('luniverse-atom-plugin.accountEmail'), atom.config.get('luniverse-atom-plugin.accountPassword')

    @luniverseCreateContractView = new LuniverseCreateContractView('')

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:create-audit', => @createAudit()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:security-assessment-reports', => @checkSecurityAssessmentReports()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse:compile-contract', => @compileContract()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse:open-setting', => @openSetting()

    @subscriptions.add atom.commands.add @luniverseCreateContractView.element,
      'luniverse:dismiss-panel', => @luniverseCreateContractView.dismissPanel()

    @subscriptions.add atom.commands.add @luniverseCreateContractView.element,
      'luniverse-signin:focus-next', => @luniverseCreateContractView.toggleFocus()

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
    @luniverseCreateContractView.destroy()

  serialize: ->

  signInLuniverse: (email, password) ->
    LuniverseApiClient.login email, password
      .then (res) ->
        if res.result && res.data.token
          atom.notifications.addSuccess('Luniverse 로그인 완료. Luniverse Api를 사용가능합니다.')
        else
          throw new Error(response.message)
      .catch (err) =>
        @openSetting()
        atom.notifications.addError('Luniverse 로그인 실패', {
          detail: error.message,
          dismissable: true
        })

  openSetting: ->
    atom.workspace.open('atom://config/packages/luniverse-atom-plugin')

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
    projectPath = helper.getUserPath()

    shell.config.execPath = shell.which('node').stdout
    shell.cd(projectPath)

    compileResult = shell.exec('./node_modules/.bin/truffle compile')
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

  deployContract: ->
    projectPath = helper.getUserPath()
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
