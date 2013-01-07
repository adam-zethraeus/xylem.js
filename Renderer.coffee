class Renderer
	constructor: (@sceneGraph, @canvas) ->
		@effects = []
		@gBuffer = new GBuffer()
	addEffect: (Effect) ->
		@effects.push(new Effect(@sceneGraph, @gBuffer))
