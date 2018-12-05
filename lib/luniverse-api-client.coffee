Rx = require 'rxjs'
rp = require 'request-promise'

module.exports =
class LuniverseApiClient

  # Properties
  @baseURL = "https://dev-be.luniverse.io/api"

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
    console.log(LuniverseApiClient.token)
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
    console.log(@baseURL + '/common-service/chains/')

    options =
      uri: @baseURL + '/common-service/chains/'
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

  @requestDeploy: (chainId, name, description, contractFileId, contract) ->
    options =
      uri: @baseURL + '/common-service/chain-contract/create'
      method: 'POST'
      form: {chainId: chainId, name: name, description: description, contractFileId: contractFileId, contract: contract}
      headers: {'dbs-auth-token': LuniverseApiClient.token}
      json: true

    req = rp(options)
    @handleAuthError req
    return req

  @handleAuthError: (promise) ->
    promise
      .then (res) ->
        if res.code is 'AUTH_REQUIRED'
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
      .catch (error) ->
        if error.error.code is 'AUTH_REQUIRED' || error.statusCode is 400
          atom.workspace.open('atom://config/packages/luniverse-atom-plugin')
