class ShaderProgram

    constructor: (@gl)->
        @program = null
        @shaders = []
        @attributes = {}

    importShader: (id)->
        script = document.getElementById(id)
        throw "shader: " + id + " could not be found." if not script
        shaderString = ""
        node = script.firstChild
        while node
            if node.nodeType
                shaderString += node.textContent
            node = node.nextSibling
        if script.type is "x-shader/x-fragment"
            glShader = @gl.createShader(@gl.FRAGMENT_SHADER)
        else if script.type is "x-shader/x-vertex"
            glShader = @gl.createShader(@gl.VERTEX_SHADER)
        @gl.shaderSource(glShader, shaderString)
        @gl.compileShader(glShader)  
        throw "A shader would not compile." if not @gl.getShaderParameter(glShader, @gl.COMPILE_STATUS)
        @shaders.push(glShader)

    linkProgram: ()->
        @program = @gl.createProgram()
        for shader in @shaders
            throw "Shader hasn't been compiled." if not @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
            @gl.attachShader(@program, shader)   
        @gl.linkProgram(@program)
        if not @gl.getProgramParameter(@program, @gl.LINK_STATUS)
            throw "Shader couldn't be linked."

    enableProgram: ()->
        if !@program
            throw "ShaderProgram must be linked before enabling it."
        @gl.useProgram(@program)

    enableAttribute: (name)->
        if !@program
            throw "ShaderProgram must be linked before enabling attribute."
        @attributes[name] = @gl.getAttribLocation(@program, name)
        @gl.enableVertexAttribArray(@attributes[name])

    disableAttribute: (name)->
        @gl.disableVertexAttribArray(getOrThrow(@attributes, name))

    getAttribute: (name)->
        return @attributes[name]

    setUniform1f: (name, value)->
        @gl.uniform1f(@gl.getUniformLocation(@program, name), value)
    
    setUniform1i: (name, value)->
        @gl.uniform1i(@gl.getUniformLocation(@program, name), value)

    setUniform2f: (name, values)->
        @gl.uniform2f(@gl.getUniformLocation(@program, name), values[0], values[1])
    
    setUniform3f: (name, values)->
        @gl.uniform3f(@gl.getUniformLocation(@program, name), values[0], values[1], values[2])

    setUniformMatrix3fv: (name, matrix)->
        @gl.uniformMatrix3fv(@gl.getUniformLocation(@program, name), false, matrix)
    
    setUniformMatrix4fv: (name, matrix)->
        @gl.uniformMatrix4fv(@gl.getUniformLocation(@program, name), false, matrix)
