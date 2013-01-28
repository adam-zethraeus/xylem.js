class SceneObject
	constructor: (@graphicalModel)->
		@modelMatrix = mat4.create()
		this.resetModelMatrix()

	translate: (vector)->
		mat4.translate(@modelMatrix, vector)
	
	rotate: (degrees, axis)->
		mat4.rotate(@modelMatrix, degToRad(degrees), axis)

	resetModelMatrix: ()->
		mat4.identity(@modelMatrix)

	getModelMatrix: ()->
		return @modelMatrix

	draw: (shaderProgram)->
		@graphicalModel.draw(shaderProgram)