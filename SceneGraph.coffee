class SceneGraph
	constructor: (json = null) ->
		@camera = null
		@triangles = []
		@lights = []
		this.loadFromJson json if json
	loadFromJson: (json) ->
		data = JSON.parse(json)
		@camera = data.camera
		@triangles = data.triangles
		@lights = data.lights
	addLight: (light) ->
		@lights.push light
	addTriangle: (triangle) ->
		@triangles.push triangle
	setCamera: (camera) ->
		@camera = camera
	logInfo: ->
		console.log @camera
		console.log @triangles
		console.log @lights
