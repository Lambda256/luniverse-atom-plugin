# solc = require 'solc'
path = require 'path'
url = require 'url'
shell = require 'shelljs'
fs = require 'fs'
{ Subject } = require 'rxjs'
{ debounceTime } = require 'rxjs/operators'

helper = require './luniverse-helper-functions'
LuniverseCreateContractView = require './luniverse-create-contract-view'
LuniverseApiClient = require './luniverse-api-client'
LuniverseAuditListView = require './luniverse-audit-list-view'

{CompositeDisposable} = require 'event-kit'

module.exports =
  luniverseCreateContractView: null
  inputSubject: new Subject()

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    shell.config.execPath = shell.which('node').stdout
    atom.config.onDidChange "luniverse-atom-plugin.accessToken", ({ newValue }) =>
      @inputSubject.next(newValue)

    @inputSubject
      .asObservable()
      .pipe(debounceTime(1000))
      .subscribe (newToken) =>
        @signInLuniverse atom.config.get('luniverse-atom-plugin.accessToken')

    @signInLuniverse atom.config.get('luniverse-atom-plugin.accessToken')

    @luniverseCreateContractView = new LuniverseCreateContractView('')

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:create-audit', => @createAudit()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse-api:security-assessment-reports', => @checkSecurityAssessmentReports()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse:compile-contract', => @compileContract()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'luniverse:open-setting', => @openSetting()

    @subscriptions.add atom.commands.add 'atom-workspace', 'luniverse:merge-solidity', => @mergeSolidity()

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

  signInLuniverse: (accessToken) ->
    LuniverseApiClient.setToken accessToken

  openSetting: ->
    atom.workspace.open('atom://config/packages/luniverse-atom-plugin')

  mergeSolidity: ->
    helper
      .mergedSourceCode(helper.getUserFilePath())
      .then (result) =>
        console.log(result)

    # if shell.exec(__dirname + '/../node_modules/sol-merger/bin/sol-merger.js ' + helper.getUserFilePath()).code is 0
    #   atom.notifications.addSuccess('Merge 성공!')
    #   filePath = atom.workspace.getActivePaneItem().buffer.file.path
    #   extname = path.extname(filePath)
    #   mergedFile = path.join(
    #     path.dirname(filePath),
    #     path.basename(filePath, extname) + '_merged' + extname
    #   )
    #   console.log(mergedFile)
    #   sourcecode = fs.readFileSync(mergedFile, 'utf8')
    #   LuniverseApiClient.compileContract sourcecode
    #     .then (res) ->
    #       console.log(res)
    #       if res.result
    #         atom.notifications.addSuccess('Contract Compile 완료. Luniverse를 통해 Deploy 요청이 가능합니다.')
    #       else
    #         throw new Error(res.message)
    #     .catch (error) ->
    #       atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
    #         detail: error.message,
    #         dismissable: true
    #       })
    # else
    #   atom.notifications.addError('Merge 실패!')

  createAudit: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor
      totalCode = editor.getText()
      LuniverseApiClient.securityAssessment(editor.getTitle(), 'code', totalCode)
        .then (res) =>
          if res.result
            atom.notifications.addSuccess('Luniverse Security Assessment 요청이 완료되었습니다!')
            @checkSecurityAssessmentReports()
          else
            throw new Error(res.message)
        .catch (error) ->
          atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
            detail: error.message,
            dismissable: true
          })

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
    LuniverseApiClient.securityAssessmentReports 1
      .then (res) =>
        if res.result && res.data.reports
          @showResults res.data.reports
        else
          throw new Error(res.message)
      .catch (error) ->
        atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
          detail: error.message,
          dismissable: true
        })

  showResults: (reportsJson) ->
    uri = 'luniverse://audit-list'
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).then (luniverseAuditListView) ->
      if luniverseAuditListView instanceof LuniverseAuditListView
        console.log('renderReports')
        console.log(reportsJson)
        luniverseAuditListView.renderReports(reportsJson)
        atom.workspace.activatePreviousPane()
