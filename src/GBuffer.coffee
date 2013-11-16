class GBuffer

    constructor: (@gl, dimensions)->
        @normalsDepthTexture = new Texture(@gl, dimensions, {internalRepresentation: @gl.FLOAT})
        @albedoTexture = new Texture(@gl, dimensions)
        @normalsDepthProgram = new ShaderProgram(@gl)
        @normalsDepthProgram.importShader("generateNormalsAndDepth_f")
        @normalsDepthProgram.importShader("generateNormalsAndDepth_v")
        @normalsDepthProgram.linkProgram()

        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.importShader("generateAlbedo_f")
        @albedoProgram.importShader("generateAlbedo_v")
        @albedoProgram.linkProgram()

    populate: (drawWithShader)->
        @normalsDepthProgram.enableProgram()
        @normalsDepthProgram.enableAttribute("vertexPosition")
        @normalsDepthProgram.enableAttribute("vertexNormal")
        @normalsDepthProgram.enableAttribute("textureCoord")
        @normalsDepthTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@normalsDepthProgram)
            true
        )
        @normalsDepthProgram.disableAttribute("vertexPosition")
        @normalsDepthProgram.disableAttribute("vertexNormal")
        @normalsDepthProgram.disableAttribute("textureCoord")

        @albedoProgram.enableProgram()
        @albedoProgram.enableAttribute("vertexPosition")
        @albedoProgram.enableAttribute("vertexNormal")
        @albedoProgram.enableAttribute("textureCoord")
        @albedoTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@albedoProgram)
            true
        )
        @albedoProgram.disableAttribute("vertexPosition")
        @albedoProgram.disableAttribute("vertexNormal")
        @albedoProgram.disableAttribute("textureCoord")