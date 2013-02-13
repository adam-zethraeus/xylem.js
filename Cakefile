fs = require 'fs'
{exec} = require 'child_process'

appFiles  = [
    'Xylem'
    'Model'
    'Texture'
    'ShaderProgram'
    'SceneNode'
    'SceneGraph'
    'ResourceLoader'
    'SceneObject'
    'SceneLight'
    'SceneCamera'
    'ProperXylem'
]

task 'build', 'Build single application file from source files', ->
    appContents = new Array remaining = appFiles.length
    for file, index in appFiles then do (file, index) ->
        fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
            throw err if err
            appContents[index] = fileContents
            process() if --remaining is 0
    process = ->
        fs.writeFile 'Xylem.coffee', appContents.join('\n\n'), 'utf8', (err) ->
            throw err if err
            exec 'coffee --compile Xylem.coffee', (err, stdout, stderr) ->
                throw err if err
                console.log stdout + stderr
                fs.unlink 'Xylem.coffee', (err) ->
                    throw err if err
                    console.log 'Done.'
