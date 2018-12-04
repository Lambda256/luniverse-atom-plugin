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
      # @div id: 'results-view', outlet: 'resultsView'
      @div id: 'load-more', class: 'load-more', click: 'loadMoreResults', outlet: 'loadMore', =>
        @a href: '#loadmore', =>
          @span  'Load More...'
      @div id: 'progressIndicator', class: 'progressIndicator', outlet: 'progressIndicator', =>
        @span class: 'loading loading-spinner-medium'

    # @div class: 'layout-atom audit-list native-key-bindings', tabindex: -1, =>
    #   @div id: 'results-view', outlet: 'resultsView'
    #   @div id: 'load-more', class: 'load-more', click: 'loadMoreResults', outlet: 'loadMore', =>
    #     @a href: '#loadmore', =>
    #       @span  'Load More...'
    #   @div id: 'progressIndicator', class: 'progressIndicator', outlet: 'progressIndicator', =>
    #     @span class: 'loading loading-spinner-medium'

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
      # Render the question headers first
      for question in reportsJson['items']
        @renderQuestionHeader(question)

    return


#
  # <div class="btns">
  #   <a href="#" class="button-normal">Detail Report</a>
  # </div>
# </div>

  renderQuestionHeader: (question) =>
    # Decode title html entities
    title = $('<div/>').html(question['reportName']).text()
    # Store the report id.
    reportId = question['reportId']

    questionHeader = $$$ ->
      @li id: reportId, =>
        @div class: 'assessment-item', =>
          @h2 class: 'assessment-item-title', title
          @div class: 'right-utils', =>
            @div class: 'time', new Date(question['createdAt']).toLocaleString()
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
            @a href: 'https://dev.luniverse.io/utility/security.assessment/report', class: 'button-normal', 'Detail Report'

      # @div id: question['question_id'], class: 'ui-result', =>
      #   @h2 class: 'title', =>
      #     @span id: "question-link-#{reportId}", class: 'underline title-string', title
      #     # Added tooltip to explain that the value is the number of votes
      #     # @div class: 'score', title: 0 + ' Votes', =>
      #     #   @p 0
      #     # Added a new badge for showing the total number of answers, and a tooltip to explain that the value is the number of answers
      #     # @div class: 'answers', title: 0 + ' Answers', =>
      #     #   @p 0
      #     # Added a check mark to show that the question has an accepted answer
      #     # @div class: 'is-accepted', =>
      #     #   @p class: 'icon icon-check', title: 'This question has an accepted answer' if true
      #   @div class: 'created', =>
      #     @text new Date(question['createdAt']).toLocaleString()
      #     # Added credits of who asked the question, with a link back to their profile
      #     @text ' - report ID: ' + reportId
      #   @div class: 'collapse-button'

    # Space-pen doesn't seem to support the data-toggle and data-target attributes
    toggleBtn = $('<button></button>', {
      id: "toggle-#{question['question_id']}",
      type: 'button',
      class: 'btn btn-info btn-xs',
      text: 'Button'
    })
    toggleBtn.attr('data-toggle', 'collapse')
    toggleBtn.attr('data-target', "#question-body-#{question['reportId']}")

    html = $(questionHeader).find('.collapse-button').append(toggleBtn).parent()
    # html = $(questionHeader).find('.collapse-button').parent()
    # @resultsView.append(html)
    @resultsView.append(questionHeader)
    return

  loadMoreResults: ->
    # progressIndicator = @progressIndicator
    # renderReports = @renderReports
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

      # , (response) =>
      #   @loadMore.show()
      #   @progressIndicator.hide()
      #   @renderReports(response.data.reports, true)
    else
      $('#load-more').children().children('span').text('No more results to load.')
