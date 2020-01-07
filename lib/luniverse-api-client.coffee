rp = require 'request-promise'
luniverseConfig = require './luniverse-config'

module.exports =
class LuniverseApiClient

  # Properties
  @baseURL = luniverseConfig.BE_API_URL
  @TOKEN_ERROR_CODES = ['AUTH_REQUIRED', 'TOKEN_REQUIRED', 'TOKEN_INVALID', 'TOKEN_EXPIRED', 'TOKEN_OUTDATED', 'TOKEN_NOTFOUND']
  # @baseURL = "http://localhost:8080/api"

  @setToken: (token) ->
    LuniverseApiClient.token = 'Bearer ' + token

  @securityAssessment: (contractName, reportType, code) ->
    console.log(@baseURL + '/common-service/security/assessment')
    options =
      uri: @baseURL + '/common-service/security/assessment'
      method: 'POST'
      form: {contractName: contractName, reportType: reportType, code: code}
      headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req

    return req

  @securityAssessmentReports: (page, callback) ->
    console.log('/common-service/security/assessment/reports?page=' + page)
    options =
      uri: @baseURL + '/common-service/security/assessment/reports?page=' + page
      method: 'GET'
      headers: {'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @getSecurityAssessmentReport: (reportId) => () =>
    console.log('/common-service/security/assessment/reports/' + reportId)
    options =
      uri: @baseURL + '/common-service/security/assessment/reports/' + reportId
      method: 'GET'
      headers: {'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @getChainList: ->
    console.log(@baseURL + '/chains/')
    options =
      uri: @baseURL + '/chains/'
      method: 'GET'
      headers: {'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @compileContract: (sourcecode, chainId = '0') ->
    # console.log(@baseURL + '/chains/' + chainId  + '/contract/files')
    console.log(@baseURL + '/chain/contract/compile')
    console.log(sourcecode)
    options =
      # uri: @baseURL + '/chains/' + chainId  + '/contract/files'
      uri: @baseURL + '/chain/contract/compile'
      method: 'POST'
      body: {sourcecode: sourcecode}
      headers: {'Content-Type': 'application/json', 'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @requestDeploy: (chainId, name, description, filename, sourcecode, compiled, contractName, params) ->
    console.log(@baseURL + '/chains/' + chainId + '/contracts')
    requestBody = {name: name, description: description, filename: filename, sourcecode: sourcecode, constructorName: contractName, constructorParams: params}

    console.log(requestBody)

    options =
      uri: @baseURL + '/chains/' + chainId + '/contracts'
      method: 'POST'
      body: requestBody
      headers: {'Content-Type': 'application/json', 'Authorization': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @handleAuthError: (promise) ->
    promise
      .then (res) =>
        if res.code in @TOKEN_ERROR_CODES
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
      .catch (error) =>
        if error.statusCode is 401 || error.error.code in @TOKEN_ERROR_CODES
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
