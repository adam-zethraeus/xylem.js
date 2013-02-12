class Model

    constructor: (@glContext)->
        @buffers = {
            vertexPositionBuffer : null,
            vertexNormalBuffer : null,
            vertexTextureCoordBuffer : null,
            vertexColourBuffer : null,
            indexBuffer : null,
        }
        @texture = null
        @textureOpacity = null

    loadModel: (model)->

        @textureOpacity = model.textureOpacity

        @buffers.vertexNormalBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexNormals), @glContext.STATIC_DRAW)
        @buffers.vertexNormalBuffer.itemSize = 3
        @buffers.vertexNormalBuffer.numItems = model.vertexNormals.length / 3

        @buffers.vertexTextureCoordBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexTextureCoords), @glContext.STATIC_DRAW)
        @buffers.vertexTextureCoordBuffer.itemSize = 2
        @buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2

        @buffers.vertexPositionBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexPositions), @glContext.STATIC_DRAW)
        @buffers.vertexPositionBuffer.itemSize = 3
        @buffers.vertexPositionBuffer.numItems = model.vertexPositions.length / 3

        @buffers.vertexColourBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexColourBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexColours), @glContext.STATIC_DRAW)
        @buffers.vertexColourBuffer.itemSize = 3
        @buffers.vertexColourBuffer.numItems = model.vertexColours.length / 3

        @buffers.indexBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)
        @glContext.bufferData(@glContext.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.indices), @glContext.STATIC_DRAW)
        @buffers.indexBuffer.itemSize = 1
        @buffers.indexBuffer.numItems = model.indices.length

    getBuffers: ()->
        return @buffers

    setTexture: (@texture)->
        return null

    draw: (shaderProgram)->
        shaderProgram.setUniform1f("textureOpacity", @textureOpacity)

        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexPositionAttribute, @buffers.vertexPositionBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
        
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().textureCoordAttribute, @buffers.vertexTextureCoordBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
        
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexNormalAttribute, @buffers.vertexNormalBuffer.itemSize, @glContext.FLOAT, false, 0, 0)

        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexColourBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexColourAttribute, @buffers.vertexColourBuffer.itemSize, @glContext.FLOAT, false, 0, 0)

        @glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)

        if @textureOpacity > 0
            @texture.bind(@glContext.TEXTURE0)
        @glContext.drawElements(@glContext.TRIANGLES, @buffers.indexBuffer.numItems, @glContext.UNSIGNED_SHORT, 0)
        # unbind texture?

    #TODO: loadFromThreeJSModel: ()->








