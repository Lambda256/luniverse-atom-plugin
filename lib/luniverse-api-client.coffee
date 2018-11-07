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
