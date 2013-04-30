class FullscreenQuad

    constructor: (@gl)->
        vertexPositions = [
            -1.0, -1.0,  0.0,
             1.0, -1.0,  0.0,
             1.0,  1.0,  0.0,
            -1.0,  1.0,  0.0
        ]
        vertexTextureCoords = [
            0.0, 0.0,
            1.0, 0.0,
            1.0, 1.0,
            0.0, 1.0
        ]
        indices = [0, 1, 2, 0, 2, 3]

        @vertexPositionBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @vertexPositionBuffer)
        @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertexPositions), @gl.STATIC_DRAW)
        @vertexPositionBuffer.itemSize = 3
        @vertexPositionBuffer.numItems = vertexPositions.length / 3

        @vertexTextureCoordBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @vertexTextureCoordBuffer)
        @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertexTextureCoords), @gl.STATIC_DRAW)
        @vertexTextureCoordBuffer.itemSize = 2
        @vertexTextureCoordBuffer.numItems = vertexTextureCoords.length / 2

        @indexBuffer = @gl.createBuffer()
        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @indexBuffer)
        @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), @gl.STATIC_DRAW)
        @indexBuffer.itemSize = 1
        @indexBuffer.numItems = indices.length

        @blitProgram = new ShaderProgram(@gl)
        @blitProgram.compileShader(
            "
                precision mediump float;
                varying vec2 vTextureCoord;
                uniform sampler2D sampler;
                void main(void) {
                    gl_FragColor = texture2D(sampler, vTextureCoord);
                }
            "
            @gl.FRAGMENT_SHADER
        )
        @blitProgram.compileShader(
            "
                attribute vec3 vertexPosition;
                attribute vec2 textureCoord;
                varying vec2 vTextureCoord;
                void main(void) {
                    gl_Position = vec4(vertexPosition, 1.0);
                    vTextureCoord = textureCoord;
                }
            "
            @gl.VERTEX_SHADER
        )
        @blitProgram.linkProgram()

    draw: (shaderProgram)->
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @vertexPositionBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("vertexPosition"), @vertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        @gl.bindBuffer(@gl.ARRAY_BUFFER, @vertexTextureCoordBuffer)
        @gl.vertexAttribPointer(shaderProgram.getAttribute("textureCoord"), @vertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)
        @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @indexBuffer)
        @gl.drawElements(@gl.TRIANGLES, @indexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)

    drawWithTexture: (texture)->
        @blitProgram.enableProgram()
        @blitProgram.enableAttribute("vertexPosition")
        @blitProgram.enableAttribute("textureCoord")
        texture.bind(0)
        @blitProgram.setUniform1i("sampler", 0)
        @draw(@blitProgram)
        @blitProgram.disableAttribute("vertexPosition")
        @blitProgram.disableAttribute("textureCoord")

