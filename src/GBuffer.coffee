class GBuffer

    constructor: (@gl, dimensions)->
        @normalsAndDepthTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @normalsAndDepthProgram = new ShaderProgram(@gl)
        @normalsAndDepthProgram.compileShader(
            "
                precision mediump float;
                varying vec2 vTextureCoord;
                varying vec3 vTransformedNormal;
                varying vec3 vColor;
                varying vec4 vPosition;
                uniform float textureOpacity;
                uniform sampler2D sampler;


                void main(void) {
                    vec4 fragmentColor = vec4(vColor, 1.0) * (1.0 - textureOpacity) + texture2D(sampler, vec2(vTextureCoord.s, vTextureCoord.t)) * textureOpacity;
                    gl_FragColor = vec4(normalize(vTransformedNormal), vPosition.z);
                }
            "
            @gl.FRAGMENT_SHADER
        )
        @normalsAndDepthProgram.compileShader(
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
        @normalsAndDepthProgram.linkProgram()

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
                    vec4 fragmentColor = vec4(vColor, 1.0) * (1.0 - textureOpacity) + texture2D(sampler, vec2(vTextureCoord.s, vTextureCoord.t)) * textureOpacity;
                    gl_FragColor = vec4(fragmentColor.rgb, fragmentColor.a);
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

    populate: (drawWithShader)->
        @normalsAndDepthProgram.enableProgram()
        @normalsAndDepthProgram.enableAttribute("vertexPosition")
        @normalsAndDepthProgram.enableAttribute("vertexNormal")
        @normalsAndDepthProgram.enableAttribute("vertexColor")
        @normalsAndDepthProgram.enableAttribute("textureCoord")
        @normalsAndDepthTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@normalsAndDepthProgram)
            true
        )
        @normalsAndDepthProgram.disableAttribute("vertexPosition")
        @normalsAndDepthProgram.disableAttribute("vertexNormal")
        @normalsAndDepthProgram.disableAttribute("vertexColor")
        @normalsAndDepthProgram.disableAttribute("textureCoord")

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
