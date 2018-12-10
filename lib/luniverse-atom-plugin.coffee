url = require 'url'
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

    @subscriptions.add atom.commands.add @luniverseCreateContractView.element,
      'luniverse:dismiss-panel', => @luniverseCreateContractView.dismissPanel()

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
    editor = atom.workspace.getActiveTextEditor()
    if editor && editor.isModified()
      atom.confirm({
        message: editor.getTitle() + ' has changes, do you want to save and compile them?',
        detail: '',
        buttons: ['Save and Compile', 'No']
      },
      (response) =>
        if response is 0
          # window.alert('good to hear')
          editor.save()
          @requestCompile()
        else
          # window.alert('bummer')
      )
    # atom.notifications.addInfo('Contract Deploy 요청중입니다...')
    # helper
    #   .mergedSourceCode(helper.getUserFilePath())
    #   .then (sourcecode) =>
    #     LuniverseApiClient.compileContract sourcecode
    #       .then (res) =>
    #         console.log(res)
    #         if res.result
    #           atom.notifications.addSuccess('Contract Compile 요청이 완료되었습니다!')
    #           # projectPath = helper.getUserPath()
    #           @luniverseCreateContractView.presentPanel res.data
    #         else
    #           throw new Error(res.message)
    #       .catch (error) ->
    #         atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
    #           detail: error.message,
    #           dismissable: true
    #         })

  requestCompile: ->
    atom.notifications.addInfo('Contract Deploy 요청중입니다...')
    helper
      .mergedSourceCode(helper.getUserFilePath())
      .then (sourcecode) =>
        LuniverseApiClient.compileContract sourcecode
          .then (res) =>
            console.log(res)
            if res.result
              atom.notifications.addSuccess('Contract Compile 요청이 완료되었습니다!')
              # projectPath = helper.getUserPath()
              @luniverseCreateContractView.presentPanel res.data
            else
              throw new Error(res.message)
          .catch (error) ->
            atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
              detail: error.message,
              dismissable: true
            })

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
