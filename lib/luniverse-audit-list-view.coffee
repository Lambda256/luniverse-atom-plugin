{$, $$$, ScrollView} = require 'atom-space-pen-views'
LuniverseApiClient = require './luniverse-api-client'

window.jQuery = $
require './vendor/bootstrap.min.js'

module.exports =
class LuniverseAuditListView extends ScrollView
  @content: ->
    @div class: 'layout-atom native-key-bindings', =>
      @h1 class: 'layout-atom-title', 'Security Assessment'
      @ul id: 'results-view', class: 'list-assessment', outlet: 'resultsView'
      @div id: 'load-more', class: 'load-more', click: 'loadMoreResults', outlet: 'loadMore', =>
        @a href: '#loadmore', =>
          @span  'Load More...'
      @div id: 'progressIndicator', class: 'progressIndicator', outlet: 'progressIndicator', =>
        @span class: 'loading loading-spinner-medium'

  initialize: ->
    super

  getTitle: ->
    'Luniverse Security Assessment'

  getURI: ->
    'luniverse://audit-list'

  getIconName: ->
    'three-bars'

  onDidChangeTitle: ->
  onDidChangeModified: ->

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderReports: (reportsJson, loadMore = false) =>
    console.log(reportsJson)
    @reportsJson = reportsJson

    # Clean up HTML if we are loading a new set of answers
    @resultsView.html('') unless loadMore

    if reportsJson['items'].length == 0
      this.html('<br><center>Audit list not found.</center>')
    else
      for report in reportsJson['items']
        @renderReportCards(report)

    return

  renderReportCards: (report) =>
    title = $('<div/>').html(report['reportName']).text()
    # Store the report id.
    reportId = report['reportId']

    reportCard = $$$ ->
      @li id: reportId, =>
        @div class: 'assessment-item', =>
          @h2 class: 'assessment-item-title', title
          @div class: 'right-utils', =>
            @div class: 'time', new Date(report['createdAt']).toLocaleString()
            @a href: '#', class: 'btn-delete', =>
              @i class: 'fa fa-close'
              @span class: 'hidden', 'delete'

          @table class: 'tbl-security-level', =>
            @caption 'Security Level'
            @tbody =>
              @tr =>
                @th rowspan: '2', class: 'security-level level-a', =>
                  @strong 'A'
                  @span 'Security Level'
                @th 'Critical'
                @th 'High'
                @th 'Medium'
                @th 'Low'
                @th 'Notie'
              @tr =>
                @td '0'
                @td '0'
                @td '0'
                @td '0'
                @td '1'

          @div class: 'btns', =>
            @a href: 'https://stg-console.luniverse.io/utility/security/assessment/report', class: 'button-normal', 'Detail Report'

    @resultsView.append(reportCard)
    return

  loadMoreResults: ->
    if @reportsJson['page'] * @reportsJson['rpp'] < @reportsJson['count']
      @progressIndicator.show()
      @loadMore.hide()
      LuniverseApiClient.securityAssessmentReports(@reportsJson['page'] + 1)
        .then (res) =>
          console.log(res)
          if res.result && res.data.reports
            @renderReports(res.data.reports, true)
          else
            throw new Error(res.message)
        .catch (error) ->
          atom.notifications.addError('Luniverse API 통신 중 오류가 발생했습니다', {
            detail: error.message,
            dismissable: true
          })
        .then =>
          @loadMore.show()
          @progressIndicator.hide()
    else
      $('#load-more').children().children('span').text('No more results to load.')
