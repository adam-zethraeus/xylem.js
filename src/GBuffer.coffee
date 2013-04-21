class GBuffer

    constructor: (@gl, dimensions)->
        @normalsAndDepthTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @normalsAndDepthProgram = new ShaderProgram(@gl)
        @normalsAndDepthProgram.compileShader(
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
        @normalsAndDepthProgram.compileShader(
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
        @normalsAndDepthProgram.linkProgram()

        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.compileShader(
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
        @albedoProgram.compileShader(
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
