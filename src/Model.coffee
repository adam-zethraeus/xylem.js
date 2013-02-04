class Model

	constructor: (@glContext)->
		@buffers = {
			vertexPositionBuffer: null
			vertexNormalBuffer: null
			vertexTextureCoordBuffer: null
			faceVertexIndexBuffer: null
		}
		@texture = null

	loadBuffers: (model)->
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

		@buffers.faceVertexIndexBuffer = @glContext.createBuffer();
		@glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.faceVertexIndexBuffer);
		@glContext.bufferData(@glContext.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.faces), @glContext.STATIC_DRAW);
		@buffers.faceVertexIndexBuffer.itemSize = 1;
		@buffers.faceVertexIndexBuffer.numItems = model.faces.length;

	getBuffers: ()->
		return @buffers

	setTexture: (@texture)->
		return null

	draw: (shaderProgram)->
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
		@glContext.vertexAttribPointer(shaderProgram.getProgram().vertexPositionAttribute, @buffers.vertexPositionBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
		
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
		@glContext.vertexAttribPointer(shaderProgram.getProgram().textureCoordAttribute, @buffers.vertexTextureCoordBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
		
		@glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
		@glContext.vertexAttribPointer(shaderProgram.getProgram().vertexNormalAttribute, @buffers.vertexNormalBuffer.itemSize, @glContext.FLOAT, false, 0, 0)

		@glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.faceVertexIndexBuffer)

		@texture.bind(@glContext.TEXTURE0)
		@glContext.drawElements(@glContext.TRIANGLES, @buffers.faceVertexIndexBuffer.numItems, @glContext.UNSIGNED_SHORT, 0)
		@texture.unbind()
	#TODO: loadFromThreeJSModel: ()->








