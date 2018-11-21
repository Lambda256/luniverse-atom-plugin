path = require('path')

module.exports =
  getUserPath: ->
    filePath = atom.workspace.getActivePaneItem().buffer.file.path
    extname = path.extname(filePath)
    console.log(path.dirname(filePath))
    console.log(path.basename(filePath, extname) + '_merged' + extname)
    projectPath = ''
    atom.project.getDirectories().forEach (dir) ->
      if dir.contains filePath
        projectPath = dir.path
    return projectPath

  getUserFilePath: ->
    return atom.workspace.getActivePaneItem().buffer.file.path
