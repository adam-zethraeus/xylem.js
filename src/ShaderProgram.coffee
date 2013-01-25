class ShaderProgram

	constructor: (@glContext)->
		@program = null
		@shaders = []

	#TODO: get rid of this.
	getShaderText: (url)->
		shaderText = null
		httpRequest = new XMLHttpRequest()
		httpRequest.addEventListener(
			"readystatechange"
			() ->
				return null if httpRequest.readyState isnt 4
				if httpRequest.status is 200
					shaderText = httpRequest.responseText
				else
					failure("A shader could not be downloaded.")
					return null
		)
		httpRequest.open("GET", url, false)
		httpRequest.send()
		return shaderText

	compileShader: (text, type)->
		glShader = @glContext.createShader(type)
		@glContext.shaderSource(glShader, text)
		@glContext.compileShader(glShader)	
		throw "A shader would not compile." if not @glContext.getShaderParameter(glShader, @glContext.COMPILE_STATUS)
		@shaders.push(glShader)


	#TODO: get all of the setUniforms out of here
	enableProgram: ()->
		@program = @glContext.createProgram()
		for shader in @shaders
			throw "Shader hasn't been compiled." if not @glContext.getShaderParameter(shader, @glContext.COMPILE_STATUS)
			@glContext.attachShader(@program, shader)	
		@glContext.linkProgram(@program)
		if not @glContext.getProgramParameter(@program, @glContext.LINK_STATUS)
			throw "Shader couldn't be linked."
		@glContext.useProgram(@program)
		
		@program.vertexPositionAttribute = @glContext.getAttribLocation(@program, "aVertexPosition")
		@glContext.enableVertexAttribArray(@program.vertexPositionAttribute)
		@program.vertexNormalAttribute = @glContext.getAttribLocation(@program, "aVertexNormal")
		@glContext.enableVertexAttribArray(@program.vertexNormalAttribute)
		@program.textureCoordAttribute = @glContext.getAttribLocation(@program, "aTextureCoord")
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


















