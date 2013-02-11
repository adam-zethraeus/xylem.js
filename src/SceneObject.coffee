class SceneObject extends SceneNode
	constructor: ()->
		super()
		@graphicalModel = null

	setModel: (@graphicalModel)->

	getGraphicalModel: ()->
		return @graphicalModel