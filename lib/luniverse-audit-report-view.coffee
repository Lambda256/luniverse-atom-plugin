{$, $$$, ScrollView} = require 'atom-space-pen-views'

window.jQuery = $
require './vendor/bootstrap.min.js'

module.exports =
class LuniverseAuditReportView extends ScrollView
  @content: ->
    @div class: 'layout-atom native-key-bindings', =>
      @h1 class: 'layout-atom-title', 'Security Assessment'
      @ul id: 'results-view', class: 'list-assessment', outlet: 'resultsView'

  initialize: ->
    super

  getTitle: ->
    'Luniverse Security Assessment Report'

  onDidChangeTitle: ->
  onDidChangeModified: ->

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderReport: (reportJson) =>
    @reportJson = reportJson

    for payload in reportJson['securityReportPayload']
      @renderReportCards payload

  renderReportCards: (payload) =>
    title = $('<div/>').html(payload['file_name']).text()
    # Store the report id.
    reportId = @reportJson['reportId']
    createdAt = @reportJson['createdAt']

    reportCard = $$$ ->
      @li id: reportId, =>
        @div class: 'assessment-item', =>
          @h2 class: 'assessment-item-title', title
          @div class: 'right-utils', =>
            @div class: 'time', new Date(createdAt).toLocaleString()
            @a href: '#', class: 'btn-delete', =>
              @i class: 'fa fa-close'
              @span class: 'hidden', 'delete'

          @table class: 'tbl-security-level', =>
            @caption 'Security Level'
            @tbody =>
              @tr =>
                @th rowspan: '2', class: 'security-level level-' + payload['security_level'].toLowerCase(), =>
                  @strong payload['security_level']
                  @span 'Security Level'
                @th 'Critical'
                @th 'High'
                @th 'Medium'
                @th 'Low'
                @th 'Note'
              @tr =>
                @td payload['criticalCount']
                @td payload['highCount']
                @td payload['mediumCount']
                @td payload['lowCount']
                @td payload['noteCount']

          @div class: 'btns', =>
            @a href: 'https://beta.luniverse.io/utility/security/assessment/report/' + reportId + '/project/' + payload['file_name'], class: 'button-normal', 'Detail Report'

    @resultsView.append(reportCard)
    return
