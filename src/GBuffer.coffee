class GBuffer

    constructor: (@gl, dimensions)->
        @normalsDepthTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @normalsDepthProgram = new ShaderProgram(@gl)
        @normalsDepthProgram.compileShader(window.XylemShaders.generateGbufferNormals.f, @gl.FRAGMENT_SHADER)
        @normalsDepthProgram.compileShader(window.XylemShaders.generateGbufferNormals.v, @gl.VERTEX_SHADER)
        @normalsDepthProgram.linkProgram()

        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.compileShader(window.XylemShaders.generateGbufferAlbedo.f, @gl.FRAGMENT_SHADER)
        @albedoProgram.compileShader(window.XylemShaders.generateGbufferAlbedo.v, @gl.VERTEX_SHADER)
        @albedoProgram.linkProgram()

    populate: (drawWithShader)->
        @normalsDepthProgram.enableProgram()
        @normalsDepthProgram.enableAttribute("vertexPosition")
        @normalsDepthProgram.enableAttribute("vertexNormal")
        @normalsDepthProgram.enableAttribute("vertexColor")
        @normalsDepthProgram.enableAttribute("textureCoord")
        @normalsDepthTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@normalsDepthProgram)
            true
        )
        @normalsDepthProgram.disableAttribute("vertexPosition")
        @normalsDepthProgram.disableAttribute("vertexNormal")
        @normalsDepthProgram.disableAttribute("vertexColor")
        @normalsDepthProgram.disableAttribute("textureCoord")

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