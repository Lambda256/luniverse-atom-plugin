rp = require 'request-promise'

module.exports =
class LuniverseApiClient

  # Properties
  @baseURL = "https://dev-be.luniverse.io/api"
  @TOKEN_ERROR_CODES = ['AUTH_REQUIRED', 'TOKEN_REQUIRED', 'TOKEN_INVALID', 'TOKEN_EXPIRED', 'TOKEN_OUTDATED', 'TOKEN_NOTFOUND']
  # @baseURL = "http://localhost:8080/api"

  @setToken: (token) ->
    LuniverseApiClient.token = token

  @securityAssessment: (contractName, contentType, code) ->
    console.log(@baseURL + '/common-service/security/assessment')
    options =
      uri: @baseURL + '/common-service/security/assessment'
      method: 'POST'
      form: {contractName: contractName, contentType: contentType, code: code}
      headers: {'Content-Type': 'application/x-www-form-urlencoded', 'dbs-auth-token': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @securityAssessmentReports: (page, callback) ->
    console.log('/common-service/security/assessment/reports?page=' + page)
    options =
      uri: @baseURL + '/common-service/security/assessment/reports?page=' + page
      method: 'GET'
      headers: {'dbs-auth-token': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @getChainList: ->
    console.log(@baseURL + '/chains/')
    options =
      uri: @baseURL + '/chains/'
      method: 'GET'
      headers: {'dbs-auth-token': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @compileContract: (sourcecode, chainId = '0') ->
    console.log(@baseURL + '/chains/' + chainId  + '/contract/files')
    options =
      uri: @baseURL + '/chains/' + chainId  + '/contract/files'
      method: 'POST'
      form: {sourcecode: sourcecode}
      headers: {'Content-Type': 'application/x-www-form-urlencoded', 'dbs-auth-token': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @requestDeploy: (chainId, name, description, contractFileId, contract, params) ->
    console.log(@baseURL + '/chains/' + chainId + '/contracts')
    options =
      uri: @baseURL + '/chains/' + chainId + '/contracts'
      method: 'POST'
      form: {chainId: chainId, name: name, description: description, contractFileId: contractFileId, contract: contract, params: JSON.stringify(params)}
      headers: {'dbs-auth-token': LuniverseApiClient.token}
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
