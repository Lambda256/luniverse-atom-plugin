Rx = require 'rxjs'
rp = require 'request-promise'

module.exports =
class LuniverseApiClient


  # Properties
  @baseURL = "https://dev-be.luniverse.io/api"
  @TOKEN_ERROR_CODES = ['AUTH_REQUIRED', 'TOKEN_REQUIRED', 'TOKEN_INVALID', 'TOKEN_EXPIRED', 'TOKEN_OUTDATED', 'TOKEN_NOTFOUND']
  # @baseURL = "http://localhost:8080/api"

  @setToken: (token) ->
    LuniverseApiClient.token = token

  @login: (email, password) ->
    options =
      uri: @baseURL + '/accounts/token'
      method: 'POST'
      form: {
        email: email,
        password: password
      }
      json: true

    req = rp(options)

    Rx.from(req)
      .subscribe(
        (res) ->
          LuniverseApiClient.token = res.data.token
      )

    return req

  @securityAssessment: (contractName, contentType, code) ->
    console.log("API Client Security Assessment")
    console.log(@baseURL + '/common-service/security/assessment')
    console.log(contractName)
    console.log(contentType)
    console.log(code)
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

  @createContract: (chainId, name, description, abi, bytecode, params) ->
    console.log(@baseURL + '/common-service/chains/' + chainId + '/contracts')
    formData = {name: name, description: description, abi: JSON.stringify(abi), bytecode: bytecode, params: JSON.stringify(params)}

    options =
      uri: @baseURL + '/common-service/chains/' + chainId + '/contracts'
      method: 'POST'
      form: formData
      headers: {'Content-Type': 'application/json', 'dbs-auth-token': LuniverseApiClient.token}
      json: true

    return rp(options)

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
    formObject = {chainId: chainId, name: name, description: description, contractFileId: contractFileId, contract: contract}
    # if params.length > 0
    formObject.params = params
    console.log(formObject)
    options =
      # uri: @baseURL + '/common-service/chain-contract/create'
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
        console.log('handleAuthError: then')
        console.log(res)
        if res.code in @TOKEN_ERROR_CODES
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
      .catch (error) =>
        console.log('handleAuthError: catch')
        console.log(error)
        if error.statusCode is 401 || error.error.code in @TOKEN_ERROR_CODES
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
