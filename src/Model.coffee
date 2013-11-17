class Model

    constructor: (@gl)->
        @buffers = {
            vertexPositionBuffer : null,
            vertexNormalBuffer : null,
            vertexTextureCoordBuffer : null,
            indexBuffer : null,
        }
        @textureOpacity = null

    loadModel: (model)->
        clr = getOrThrow(model, "baseColor");
        @baseColor = {"r":getOrThrow(clr,"r"), "g": getOrThrow(clr,"g"), "b": getOrThrow(clr,"b")}
        @textureOpacity = getOrThrow(model, "textureOpacity")
        @hasTexture = @textureOpacity > 0

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

        if @hasTexture
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
        shaderProgram.enableAttribute("vertexPosition")
        shaderProgram.enableAttribute("vertexNormal")
        if @hasTexture
            shaderProgram.enableAttribute("textureCoord")
        shaderProgram.setUniform1f("textureOpacity", @textureOpacity)
        shaderProgram.setUniform3f("baseColor", [@baseColor.r, @baseColor.g, @baseColor.b])
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexPosition"), @buffers.vertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        if @hasTexture
            @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexTextureCoordBuffer)
            @gl.vertexAttribPointer(shaderProgram.getAttribute("textureCoord"), @buffers.vertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexNormalBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexNormal"), @buffers.vertexNormalBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)
        bindLocation = 0
        if @hasTexture
            texture.bind(bindLocation)
            shaderProgram.setUniform1i("sampler", bindLocation)
        @gl.drawElements(@gl.TRIANGLES, @buffers.indexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)
        if @hasTexture
            texture.unbind(bindLocation)
            shaderProgram.disableAttribute("textureCoord")
        shaderProgram.disableAttribute("vertexPosition")
        shaderProgram.disableAttribute("vertexNormal")

    drawLines: (shaderProgram)->
        shaderProgram.enableAttribute("vertexPosition")
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @buffers.vertexPositionBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexPosition"), @buffers.vertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @buffers.indexBuffer)
        for i in [0 .. @buffers.indexBuffer.numItems - 3] by 3
            @gl.drawElements(@gl.LINE_LOOP, 3, @gl.UNSIGNED_SHORT, i * 2)
        shaderProgram.disableAttribute("vertexPosition")
