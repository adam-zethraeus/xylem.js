class ShaderProgram

	constructor: (@glContext)->
		@program = null
		@shaders = []

	compileShader: (text, type)->
		glShader = @glContext.createShader(type)
		@glContext.shaderSource(glShader, text)
		@glContext.compileShader(glShader)	
		throw "A shader would not compile." if not @glContext.getShaderParameter(glShader, @glContext.COMPILE_STATUS)
		@shaders.push(glShader)

	enableProgram: ()->
		@program = @glContext.createProgram()
		for shader in @shaders
			throw "Shader hasn't been compiled." if not @glContext.getShaderParameter(shader, @glContext.COMPILE_STATUS)
			@glContext.attachShader(@program, shader)	
		@glContext.linkProgram(@program)
		if not @glContext.getProgramParameter(@program, @glContext.LINK_STATUS)
			throw "Shader couldn't be linked."
		@glContext.useProgram(@program)

		@program.vertexPositionAttribute = @glContext.getAttribLocation(@program, "vertexPosition")
		@glContext.enableVertexAttribArray(@program.vertexPositionAttribute)
		@program.vertexNormalAttribute = @glContext.getAttribLocation(@program, "vertexNormal")
		@glContext.enableVertexAttribArray(@program.vertexNormalAttribute)
		@program.textureCoordAttribute = @glContext.getAttribLocation(@program, "textureCoord")
		@glContext.enableVertexAttribArray(@program.textureCoordAttribute)

	setUniform1f: (name, value)->
		@glContext.uniform1f(@glContext.getUniformLocation(@program, name), value)
	
	setUniform1i: (name, value)->
		@glContext.uniform1i(@glContext.getUniformLocation(@program, name), value)
	
	setUniform3f: (name, values)->
		@glContext.uniform3f(@glContext.getUniformLocation(@program, name), values[0], values[1], values[2])

	setUniformMatrix3fv: (name, matrix)->
		@glContext.uniformMatrix3fv(@glContext.getUniformLocation(@program, name), false, matrix)
	
	setUniformMatrix4fv: (name, matrix)->
		@glContext.uniformMatrix4fv(@glContext.getUniformLocation(@program, name), false, matrix)


	getProgram: ()->
		return @program


















