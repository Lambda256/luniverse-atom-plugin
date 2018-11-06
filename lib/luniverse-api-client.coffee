request = require 'request'

module.exports =
class LuniverseApiClient

  # Properties
  @token = null

  @login: (email, password, callback) ->
    options =
      uri: "https://pre-be.luniverse.io/api/accounts/token"
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
          callback(response)
      else
        console.log "Error: #{error}", "Result: ", res
        response = null
