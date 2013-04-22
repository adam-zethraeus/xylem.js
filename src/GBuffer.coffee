class GBuffer

    constructor: (@gl, dimensions)->
        @normalsTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @positionTexture = new Texture(@gl, dimensions)
        @normalsProgram = new ShaderProgram(@gl)
        @normalsProgram.compileShader(
            "
                precision mediump float;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                uniform float textureOpacity;
                uniform sampler2D sampler;
                void main(void) {
                    gl_FragColor = vec4(normalize(vTransformedNormal), 1.0);
                }
            "
            @gl.FRAGMENT_SHADER
        )
        @normalsProgram.compileShader(
            "
                attribute vec3 vertexPosition;
                attribute vec3 vertexNormal;
                attribute vec3 vertexColor;
                attribute vec2 textureCoord;
                uniform mat4 mvMatrix;
                uniform mat4 pMatrix;
                uniform mat3 nMatrix;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                void main(void) {
                    vPosition = mvMatrix * vec4(vertexPosition, 1.0);
                    gl_Position = pMatrix * vPosition;
                    vTextureCoord = textureCoord;
                    vColor = vertexColor;
                    vTransformedNormal = nMatrix * vertexNormal;
                }
            "
            @gl.VERTEX_SHADER
        )
        @normalsProgram.linkProgram()

        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.compileShader(
            "
                precision mediump float;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                uniform float textureOpacity;
                uniform sampler2D sampler;
                void main(void) {
                    gl_FragColor =  vec4(vColor, 1.0) * (1.0 - textureOpacity) + texture2D(sampler, vec2(vTextureCoord.s, vTextureCoord.t)) * textureOpacity;
                }
            "
            @gl.FRAGMENT_SHADER
        )
        @albedoProgram.compileShader(
            "
                attribute vec3 vertexPosition;
                attribute vec3 vertexNormal;
                attribute vec3 vertexColor;
                attribute vec2 textureCoord;
                uniform mat4 mvMatrix;
                uniform mat4 pMatrix;
                uniform mat3 nMatrix;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                void main(void) {
                    vPosition = mvMatrix * vec4(vertexPosition, 1.0);
                    gl_Position = pMatrix * vPosition;
                    vTextureCoord = textureCoord;
                    vColor = vertexColor;
                    vTransformedNormal = nMatrix * vertexNormal;
                }
            "
            @gl.VERTEX_SHADER
        )
        @albedoProgram.linkProgram()

        @positionProgram = new ShaderProgram(@gl)
        @positionProgram.compileShader(
            "
                precision mediump float;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                uniform float textureOpacity;
                uniform sampler2D sampler;
                void main(void) {
                    gl_FragColor = vPosition;
                }
            "
            @gl.FRAGMENT_SHADER
        )
        @positionProgram.compileShader(
            "
                attribute vec3 vertexPosition;
                attribute vec3 vertexNormal;
                attribute vec3 vertexColor;
                attribute vec2 textureCoord;
                uniform mat4 mvMatrix;
                uniform mat4 pMatrix;
                uniform mat3 nMatrix;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                void main(void) {
                    vPosition = mvMatrix * vec4(vertexPosition, 1.0);
                    gl_Position = pMatrix * vPosition;
                    vTextureCoord = textureCoord;
                    vColor = vertexColor;
                    vTransformedNormal = nMatrix * vertexNormal;
                }
            "
            @gl.VERTEX_SHADER
        )
        @positionProgram.linkProgram()

    populate: (drawWithShader)->
        @normalsProgram.enableProgram()
        @normalsProgram.enableAttribute("vertexPosition")
        @normalsProgram.enableAttribute("vertexNormal")
        @normalsProgram.enableAttribute("vertexColor")
        @normalsProgram.enableAttribute("textureCoord")
        @normalsTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@normalsProgram)
            true
        )
        @normalsProgram.disableAttribute("vertexPosition")
        @normalsProgram.disableAttribute("vertexNormal")
        @normalsProgram.disableAttribute("vertexColor")
        @normalsProgram.disableAttribute("textureCoord")

        @albedoProgram.enableProgram()
        @albedoProgram.enableAttribute("vertexPosition")
        @albedoProgram.enableAttribute("vertexNormal")
        @albedoProgram.enableAttribute("vertexColor")
        @albedoProgram.enableAttribute("textureCoord")
        @albedoTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@albedoProgram)
            true
        )
        @albedoProgram.disableAttribute("vertexPosition")
        @albedoProgram.disableAttribute("vertexNormal")
        @albedoProgram.disableAttribute("vertexColor")
        @albedoProgram.disableAttribute("textureCoord")

        @positionProgram.enableProgram()
        @positionProgram.enableAttribute("vertexPosition")
        @positionProgram.enableAttribute("vertexNormal")
        @positionProgram.enableAttribute("vertexColor")
        @positionProgram.enableAttribute("textureCoord")
        @positionTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@positionProgram)
            true
        )
        @positionProgram.disableAttribute("vertexPosition")
        @positionProgram.disableAttribute("vertexNormal")
        @positionProgram.disableAttribute("vertexColor")
        @positionProgram.disableAttribute("textureCoord")