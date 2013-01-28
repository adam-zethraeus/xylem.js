class SceneNode
	constructor: (@graphicalModel)->
		@modelMatrix = mat4.create()
		@childNodes = []
		@parentNode = null
		this.resetModelMatrix()

	translate: (vector)->
		mat4.translate(@modelMatrix, vector)
	
	rotate: (degrees, axis)->
		mat4.rotate(@modelMatrix, degToRad(degrees), axis)

	scale: (proportion) ->
		#TODO: implement

	resetModelMatrix: ()->
		mat4.identity(@modelMatrix)

	getModelMatrix: ()->
		return @modelMatrix

	addChild: (node)->
		node.setParent(this)
		@childNodes.push(node)

	reparentTo: (node)->
		if @parentNode
			@parentNode.removeChild(this)
		node.addChild(this)

	setParent: (@parentNode)->

	removeChild: (node)->
		#TODO: implement

	getChildren: ()->
		return @childNodes

	draw: (shaderProgram)->
		@graphicalModel.draw(shaderProgram)