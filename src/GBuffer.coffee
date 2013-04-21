class GBuffer

    constructor: (@gl, dimensions)->
        @normalsAndDepthTexture = new Texture(@gl, dimensions)
        @albedoTexture = new Texture(@gl, dimensions)
        @normalsAndDepthShader = new ShaderProgram(@gl)
        @normalsAndDepthShader.compileShader("//fragment shader text", @gl.FRAGMENT_SHADER)
        @normalsAndDepthShader.compileShader("//vertex shader text", @gl.VERTEX_SHADER)

        @albedoShader = new ShaderProgram(@gl)

    populate: (drawWithShader)->
        @normalsAndDepthShader.enableProgram()
        @normalsAndDepthShader.enableAttribute("vertexPosition")
        @normalsAndDepthShader.enableAttribute("vertexNormal")
        @normalsAndDepthShader.enableAttribute("vertexColor")
        @normalsAndDepthShader.enableAttribute("textureCoord")
        @normalsAndDepthTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@normalsAndDepthShader)
            true
        )
        @normalsAndDepthShader.disableAttribute("vertexPosition")
        @normalsAndDepthShader.disableAttribute("vertexNormal")
        @normalsAndDepthShader.disableAttribute("vertexColor")
        @normalsAndDepthShader.disableAttribute("textureCoord")

        @albedoShader.enableProgram()
        @albedoShader.enableAttribute("vertexPosition")
        @albedoShader.enableAttribute("vertexNormal")
        @albedoShader.enableAttribute("vertexColor")
        @albedoShader.enableAttribute("textureCoord")
        @albedoTexture.drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                drawWithShader(@albedoShader)
            true
        )
        @albedoShader.disableAttribute("vertexPosition")
        @albedoShader.disableAttribute("vertexNormal")
        @albedoShader.disableAttribute("vertexColor")
        @albedoShader.disableAttribute("textureCoord")
