request = require 'request'

module.exports =
class LuniverseApiClient

  # Properties
  @baseURL = "https://dev-be.luniverse.io/api"

  @setToken: (token) ->
    LuniverseApiClient.token = token

  @login: (email, password, callback) ->
    options =
      uri: @baseURL + "/accounts/token"
      method: 'POST'
      form: {email: email, password: password}

    request options, (error, res, body) ->
      console.log(res)
      console.log(body)
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          LuniverseApiClient.token = response.data.token
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
        callback(response)

  @securityAssessment: (contractName, contentType, code, callback) ->
    console.log("API Client Security Assessment")
    console.log(LuniverseApiClient.token)
    options =
      uri: @baseURL + '/common-service/security/assessment'
      method: 'POST'
      form: {contractName: contractName, contentType: contentType, code: code}
      headers: {'Content-Type': 'application/x-www-form-urlencoded', 'dbs-auth-token': LuniverseApiClient.token}

    request options, (error, res, body) ->
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
        callback(response)

  @securityAssessmentReports: (page, callback) ->
    console.log('/common-service/security/assessment/reports?page=' + page)

    options =
      uri: @baseURL + '/common-service/security/assessment/reports?page=' + page
      method: 'GET'
      headers: {'dbs-auth-token': LuniverseApiClient.token}

    request options, (error, res, body) ->
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
        callback(response)

  @getChainList: (callback) ->
    console.log(@baseURL + '/common-service/chains/')

    options =
      uri: @baseURL + '/common-service/chains/'
      method: 'GET'
      headers: {'dbs-auth-token': LuniverseApiClient.token}

    request options, (error, res, body) ->
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
        callback(response)

  @createContract: (chainId, name, description, abi, bytecode, params, callback) ->
    console.log('https://pre-be.luniverse.io/api/common-service/chain/1542007938176586187/contracts')
    formData = {name: name, description: description, abi: JSON.stringify(abi), bytecode: bytecode, params: JSON.stringify(params)}
    console.log(formData)
    options =
      uri: 'https://pre-be.luniverse.io/api/common-service/chain/1542007938176586187/contracts'
      method: 'POST'
      form: formData
      headers: {'Content-Type': 'application/json', 'dbs-auth-token': '6LT4nvDI1ei/NJQC3bfc7f9EAYiAJ77YozB+MqZw8JB3KAm3ETzAtTeA957OMeK4UUkz2lD3nlHdO3S4ZgPOHGY/UQmIVJ8Ojo8kP2O8HWSi2rJYjcLDkl0sNUwyJMTpEDF0ZlfLOQ1IvNOXfx4qSXEdsvSPGt2ZElMAws6T89l1U+/ELjaYrfdMpEcin8UaqJ37Jtpu8sygkPMN/ysnpAsllQW5QauMrG15mf5SKIEjjjN+aKQ8ITBT/e4Jg56srlDlvjeWAtM3cW/Sam/NvWljyNsRPAueDcYiwQ0ejBRbXNBSUC/6PwY+CTKsW0juyuhQTiNXVpKsdfDdSmYcJqV6viZVKtIFLl2y3RIOgd6CVHWfrTQ4elr17FFADEpNXQwcpMLGJ7QMo1e6SOMSUw=='}

    request options, (error, res, body) ->
      if not error and res.statusCode is 200
        try
          response = JSON.parse(body)
        catch
          console.log "Error: Invalid JSON"
          response = null
        finally
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
        callback(response)
