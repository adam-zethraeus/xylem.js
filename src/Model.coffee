class Model

    constructor: (@gl)->
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

        @buffers.vertexNormalBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(model.vertexNormals), @gl.STATIC_DRAW)
        @buffers.vertexNormalBuffer.itemSize = 3
        @buffers.vertexNormalBuffer.numItems = model.vertexNormals.length / 3

        @buffers.vertexPositionBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(model.vertexPositions), @gl.STATIC_DRAW)
        @buffers.vertexPositionBuffer.itemSize = 3
        @buffers.vertexPositionBuffer.numItems = model.vertexPositions.length / 3

        if @textureOpacity is 1.0
            # This is a dirty hack. It's probably better to just enforce model textures.
            @buffers.vertexColorBuffer = @buffers.vertexNormalBuffer
        else
            @buffers.vertexColorBuffer = @gl.createBuffer()
            @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexColorBuffer)
            @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(model.vertexColors), @gl.STATIC_DRAW)
            @buffers.vertexColorBuffer.itemSize = 3
            @buffers.vertexColorBuffer.numItems = model.vertexColors.length / 3

        if @textureOpacity is 0.0
            # This is an even dirtier hack. It's probably better to just enforce model textures.
            @buffers.vertexTextureCoordBuffer = @gl.createBuffer()
            @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
            @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(model.indices.concat(model.indices)), @gl.STATIC_DRAW)
            @buffers.vertexTextureCoordBuffer.itemSize = 2
            @buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2
        else
            @buffers.vertexTextureCoordBuffer = @gl.createBuffer()
            @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
            @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(model.vertexTextureCoords), @gl.STATIC_DRAW)
            @buffers.vertexTextureCoordBuffer.itemSize = 2
            @buffers.vertexTextureCoordBuffer.numItems = model.vertexTextureCoords.length / 2

        @buffers.indexBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)
        @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.indices), @gl.STATIC_DRAW)
        @buffers.indexBuffer.itemSize = 1
        @buffers.indexBuffer.numItems = model.indices.length

    getBuffers: ()->
        return @buffers

    draw: (shaderProgram, texture)->
        shaderProgram.setUniform1f("textureOpacity", @textureOpacity)

        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexPosition"), @buffers.vertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("textureCoord"), @buffers.vertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexNormal"), @buffers.vertexNormalBuffer.itemSize, @gl.FLOAT, false, 0, 0)

        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexColorBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexColor"), @buffers.vertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0)

        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)

        bindLocation = 0
        if @textureOpacity > 0
            if not texture?
                throw "A model could not be drawn without a passed texture."
            texture.bind(bindLocation)
            shaderProgram.setUniform1i("sampler", bindLocation)
        @gl.drawElements(@gl.TRIANGLES, @buffers.indexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)
        if @textureOpacity > 0
            texture.unbind(bindLocation)








