class ShaderProgram

    constructor: (@gl)->
        @program = null
        @shaders = []

    compileShader: (text, type)->
        glShader = @gl.createShader(type)
        @gl.shaderSource(glShader, text)
        @gl.compileShader(glShader)  
        throw "A shader would not compile." if not @gl.getShaderParameter(glShader, @gl.COMPILE_STATUS)
        @shaders.push(glShader)

    enableProgram: ()->
        @program = @gl.createProgram()
        for shader in @shaders
            throw "Shader hasn't been compiled." if not @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
            @gl.attachShader(@program, shader)   
        @gl.linkProgram(@program)
        if not @gl.getProgramParameter(@program, @gl.LINK_STATUS)
            throw "Shader couldn't be linked."
        @gl.useProgram(@program)

        @program.vertexPositionAttribute = @gl.getAttribLocation(@program, "vertexPosition")
        @gl.enableVertexAttribArray(@program.vertexPositionAttribute)
        @program.vertexNormalAttribute = @gl.getAttribLocation(@program, "vertexNormal")
        @gl.enableVertexAttribArray(@program.vertexNormalAttribute)
        @program.vertexColorAttribute = @gl.getAttribLocation(@program, "vertexColor")
        @gl.enableVertexAttribArray(@program.vertexColorAttribute)
        @program.textureCoordAttribute = @gl.getAttribLocation(@program, "textureCoord")
        @gl.enableVertexAttribArray(@program.textureCoordAttribute)

    setUniform1f: (name, value)->
        @gl.uniform1f(@gl.getUniformLocation(@program, name), value)
    
    setUniform1i: (name, value)->
        @gl.uniform1i(@gl.getUniformLocation(@program, name), value)
    
    setUniform3f: (name, values)->
        @gl.uniform3f(@gl.getUniformLocation(@program, name), values[0], values[1], values[2])

    setUniformMatrix3fv: (name, matrix)->
        @gl.uniformMatrix3fv(@gl.getUniformLocation(@program, name), false, matrix)
    
    setUniformMatrix4fv: (name, matrix)->
        @gl.uniformMatrix4fv(@gl.getUniformLocation(@program, name), false, matrix)

    getProgram: ()->
        return @program


















