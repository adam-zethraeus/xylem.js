class SceneNode
	constructor: ()->
		@modelMatrix = mat4.create()
		@children = []
		@parentNode = null
		this.resetModelMatrix()

	setModel: (@graphicalModel)->

	getGraphicalModel: ()->
		throw "Model not set" if not @graphicalModel?
		return @graphicalModel

	translate: (vector)->
		mat4.translate(@modelMatrix, vector)
	
	rotate: (degrees, axis)->
		mat4.rotate(@modelMatrix, degToRad(degrees), axis)

	scale: (proportion) ->
		mat4.scale(@modelMatrix, proportion)

	resetModelMatrix: ()->
		mat4.identity(@modelMatrix)

	getModelMatrix: ()->
		return @modelMatrix

	addChild: (node)->
		node.setParent(this)
		@children.push(node)

	reparentTo: (node)->
		if @parentNode
			@parentNode.removeChild(this)
		node.addChild(this)

	setParent: (@parentNode)->

	removeChild: (node)->
		index = @children.indexOf(node)
		return if index is -1
		@children = @children.slice(0, index) + @children.slice(index + 1)

	getChildren: ()->
		return @children

	#TODO: refactor this out
	draw: (shaderProgram)->
		throw "Model not set" if not @graphicalModel?
		@graphicalModel.draw(shaderProgram)