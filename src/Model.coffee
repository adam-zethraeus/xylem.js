class Model

    constructor: (@glContext)->
        @buffers = {
            vertexPositionBuffer : null,
            vertexNormalBuffer : null,
            vertexTextureCoordBuffer : null,
            vertexColorBuffer : null,
            indexBuffer : null,
        }
        @textureOpacity = null

    loadModel: (model)->

        @textureOpacity = model.textureOpacity

        @buffers.vertexNormalBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexNormals), @glContext.STATIC_DRAW)
        @buffers.vertexNormalBuffer.itemSize = 3
        @buffers.vertexNormalBuffer.numItems = model.vertexNormals.length / 3

        @buffers.vertexPositionBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexPositions), @glContext.STATIC_DRAW)
        @buffers.vertexPositionBuffer.itemSize = 3
        @buffers.vertexPositionBuffer.numItems = model.vertexPositions.length / 3

        if @textureOpacity is 1.0
            # This is a dirty hack. It's probably better to just enforce model textures.
            @buffers.vertexColorBuffer = @buffers.vertexNormalBuffer
        else
            @buffers.vertexColorBuffer = @glContext.createBuffer()
            @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexColorBuffer)
            @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexColors), @glContext.STATIC_DRAW)
            @buffers.vertexColorBuffer.itemSize = 3
            @buffers.vertexColorBuffer.numItems = model.vertexColors.length / 3

        if @textureOpacity is 0.0
            # This is an even dirtier hack. It's probably better to just enforce model textures.
            @buffers.vertexTextureCoordBuffer = @glContext.createBuffer()
            @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
            @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.indices.concat(model.indices)), @glContext.STATIC_DRAW)
            @buffers.vertexTextureCoordBuffer.itemSize = 2
            @buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2
        else
            @buffers.vertexTextureCoordBuffer = @glContext.createBuffer()
            @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
            @glContext.bufferData(@glContext.ARRAY_BUFFER, new Float32Array(model.vertexTextureCoords), @glContext.STATIC_DRAW)
            @buffers.vertexTextureCoordBuffer.itemSize = 2
            @buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2

        @buffers.indexBuffer = @glContext.createBuffer()
        @glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)
        @glContext.bufferData(@glContext.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.indices), @glContext.STATIC_DRAW)
        @buffers.indexBuffer.itemSize = 1
        @buffers.indexBuffer.numItems = model.indices.length

    getBuffers: ()->
        return @buffers

    draw: (shaderProgram, texture)->
        shaderProgram.setUniform1f("textureOpacity", @textureOpacity)

        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexPositionAttribute, @buffers.vertexPositionBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
        
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().textureCoordAttribute, @buffers.vertexTextureCoordBuffer.itemSize, @glContext.FLOAT, false, 0, 0)
        
        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexNormalAttribute, @buffers.vertexNormalBuffer.itemSize, @glContext.FLOAT, false, 0, 0)

        @glContext.bindBuffer(@glContext.ARRAY_BUFFER, @buffers.vertexColorBuffer)
        @glContext.vertexAttribPointer(shaderProgram.getProgram().vertexColorAttribute, @buffers.vertexColorBuffer.itemSize, @glContext.FLOAT, false, 0, 0)

        @glContext.bindBuffer(@glContext.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)

        if @textureOpacity > 0
            if not texture?
                throw "A model could not be drawn without a passed texture."
            bindLocation = 0
            texture.bind(bindLocation)
            shaderProgram.setUniform1i("sampler", bindLocation)
        @glContext.drawElements(@glContext.TRIANGLES, @buffers.indexBuffer.numItems, @glContext.UNSIGNED_SHORT, 0)

    #TODO: loadFromThreeJSModel: ()->








