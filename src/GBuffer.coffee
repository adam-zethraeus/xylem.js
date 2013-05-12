class GBuffer

    constructor: (@gl, dimensions)->
        @normalsTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @positionTexture = new Texture(@gl, dimensions)
        @normalsProgram = new ShaderProgram(@gl)
        @normalsProgram.compileShader(window.XylemShaders.generateGbufferNormals.f, @gl.FRAGMENT_SHADER)
        @normalsProgram.compileShader(window.XylemShaders.generateGbufferNormals.v, @gl.VERTEX_SHADER)
        @normalsProgram.linkProgram()

        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.compileShader(window.XylemShaders.generateGbufferAlbedo.f, @gl.FRAGMENT_SHADER)
        @albedoProgram.compileShader(window.XylemShaders.generateGbufferAlbedo.v, @gl.VERTEX_SHADER)
        @albedoProgram.linkProgram()

        @positionProgram = new ShaderProgram(@gl)
        @positionProgram.compileShader(window.XylemShaders.generateGbufferPosition.f, @gl.FRAGMENT_SHADER)
        @positionProgram.compileShader(window.XylemShaders.generateGbufferPosition.v, @gl.VERTEX_SHADER)
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