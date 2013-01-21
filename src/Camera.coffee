class Camera
	constructor: () ->
		@modelMatrix = mat4.create()
		@projectionMatrix = mat4.create()

	setPosition: (location)->

	
	setDirection: (direction)->

	
	setProperties: (fov, viewportWidth, viewportHeight, nearClip, farClip)->
		mat4.perspective(fov, viewportWidth / viewportHeight, nearClip, farClip, @projectionMatrix)
	
	getModelMatrix: ()->
		return @modelMatrix

	getProjectionMatix: ()->
		return @projection

	getViewMatrix: ()->
		viewMatrix = mat4.create()
		mat4.inverse(@modelMatrix, viewMatrix)
		return viewMatrix