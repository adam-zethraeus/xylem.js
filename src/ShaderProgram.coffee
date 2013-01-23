class ShaderProgram

	constructor: (@glContext)->
		@program = null

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

	compileShader: (shaderText, glShaderType)->
		shader = @glContext.createShader(glShaderType)
		@glContext.shaderSource(shader, shaderText)
		@glContext.compileShader(shader)
		if not @glContext.getShaderParameter(shader, @glContext.COMPILE_STATUS)
			failure("A shader would not compile.", @glContext.getShaderInfoLog(shader))
			return null
		else 
			return shader

	#TODO: get all of the setUniforms out of here
	initializeProgram: (vertexShader, fragmentShader)->
		if not @glContext.getShaderParameter(vertexShader, @glContext.COMPILE_STATUS) or not @glContext.getShaderParameter(fragmentShader, @glContext.COMPILE_STATUS)
			throw "shaders haven't been compiled"
		@program = @glContext.createProgram()
		@glContext.attachShader(@program, vertexShader)
		@glContext.attachShader(@program, fragmentShader)
		@glContext.linkProgram(@program)
		if not @glContext.getProgramParameter(@program, @glContext.LINK_STATUS)
			failure("Could not link a program.")
			return null
		@glContext.useProgram(@program)
		@program.vertexPositionAttribute = @glContext.getAttribLocation(@program, "aVertexPosition")
		@glContext.enableVertexAttribArray(@program.vertexPositionAttribute)
		@program.vertexNormalAttribute = @glContext.getAttribLocation(@program, "aVertexNormal")
		@glContext.enableVertexAttribArray(@program.vertexNormalAttribute)
		@program.textureCoordAttribute = @glContext.getAttribLocation(@program, "aTextureCoord")
		@glContext.enableVertexAttribArray(@program.textureCoordAttribute)
		@program.pMatrixUniform = @glContext.getUniformLocation(@program, "uPMatrix")
		@program.mvMatrixUniform = @glContext.getUniformLocation(@program, "uMVMatrix")
		@program.nMatrixUniform = @glContext.getUniformLocation(@program, "uNMatrix")
		@program.samplerUniform = @glContext.getUniformLocation(@program, "uSampler")
		@program.materialShininessUniform = @glContext.getUniformLocation(@program, "uMaterialShininess")
		@program.useTexturesUniform = @glContext.getUniformLocation(@program, "uUseTextures")
		@program.ambientColorUniform = @glContext.getUniformLocation(@program, "uAmbientColor")
		@program.pointLightingLocationUniform = @glContext.getUniformLocation(@program, "uPointLightingLocation")
		@program.pointLightingSpecularColorUniform = @glContext.getUniformLocation(@program, "uPointLightingSpecularColor")
		@program.pointLightingDiffuseColorUniform = @glContext.getUniformLocation(@program, "uPointLightingDiffuseColor")
		return @program

	getProgram: ()->
		return @program