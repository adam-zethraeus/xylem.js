class Model

	constructor: (glContext, url)->
		@glContext = glContext
		@buffers = {
			vertexPositionBuffer: null
			vertexNormalBuffer: null
			vertexTextureCoordBuffer: null
			vertexIndexBuffer: null
		}
		this.loadBuffersFromJSON(url)

	loadBuffersFromJSON: (url)->
		console.log("load")
		model = null
		httpRequest = new XMLHttpRequest()
		httpRequest.addEventListener(
			"readystatechange"
			() ->
				return null if httpRequest.readyState isnt 4
				if httpRequest.status is 200
					model = JSON.parse(httpRequest.responseText)
				else
					failure("A model could not be downloaded.")
					return null
		)
		# used synchronously
		httpRequest.open("GET", url, false)
		httpRequest.send()
		# Model has now been set
		@buffers.vertexNormalBuffer = @glContext.createBuffer();
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer);
		@glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexNormals), @glContext.STATIC_DRAW);
		@buffers.vertexNormalBuffer.itemSize = 3;
		@buffers.vertexNormalBuffer.numItems = model.vertexNormals.length / 3;

		@buffers.vertexTextureCoordBuffer = @glContext.createBuffer();
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer);
		@glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexTextureCoords), @glContext.STATIC_DRAW);
		@buffers.vertexTextureCoordBuffer.itemSize = 2;
		@buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2;

		@buffers.vertexPositionBuffer = @glContext.createBuffer();
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer);
		@glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexPositions), @glContext.STATIC_DRAW);
		@buffers.vertexPositionBuffer.itemSize = 3;
		@buffers.vertexPositionBuffer.numItems = model.vertexPositions.length / 3;

		@buffers.vertexIndexBuffer = @glContext.createBuffer();
		@glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.vertexIndexBuffer);
		@glContext.bufferData(@glContext.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.indices), @glContext.STATIC_DRAW);
		@buffers.vertexIndexBuffer.itemSize = 1;
		@buffers.vertexIndexBuffer.numItems = model.indices.length;

	getBuffers: ()->
		return @buffers

	#TODO: loadFromThreeJSModel: ()->