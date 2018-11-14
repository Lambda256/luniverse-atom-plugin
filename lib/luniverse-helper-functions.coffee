module.exports =
  getUserPath: ->
    filePath = atom.workspace.getActivePaneItem().buffer.file.path
    projectPath = ''
    atom.project.getDirectories().forEach (dir) ->
      if dir.contains filePath
        projectPath = dir.path
    return projectPath
