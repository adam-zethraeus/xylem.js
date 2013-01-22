window.onload = () ->
	xylem()

mvMatrix = mat4.create()
pMatrix = mat4.create()
shaderProgram = null
gl = null
camera = null

xylem = () ->
	canvas = document.getElementById("render_canvas")
	gl = initializeGL(canvas)
	shaderProgram = getInitializedShaderProgram()
	teapot = new Model(gl, "models/teapot.json")
	camera = new Camera()
	camera.setProperties(20, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
	pMatrix = camera.getProjectionMatrix()
	camera.translate([0,0,20])
	camera.rotate(5, [0, 1, 0])
	gl.clearColor(0.0, 0.0, 0.0, 1.0)
	gl.enable(gl.DEPTH_TEST)
	barrier = new Barrier()
	textures = {
		"earth": initializeTexture("textures/earth.jpg", barrier.getCallback())
		"metal": initializeTexture("textures/metal.jpg", barrier.getCallback())
	}
	barrier.finalize(()->
		draw(teapot.getBuffers(), textures)
	)

setMatrixUniforms = () ->
	gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix)
	gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix)
	normalMatrix = mat3.create()
	mat4.toInverseMat3(mvMatrix, normalMatrix)
	mat3.transpose(normalMatrix)
	gl.uniformMatrix3fv(shaderProgram.nMatrixUniform, false, normalMatrix)

degToRad = (degrees) ->
	return degrees * (Math.PI / 180);

draw = (buffers, textures) ->
	gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	texture = "metal"
	gl.uniform3f(shaderProgram.ambientColorUniform, 0.2, 0.2, 0.2)
	gl.uniform3f(shaderProgram.pointLightingLocationUniform, -10.0, 4.0, -20.0)
	gl.uniform3f(shaderProgram.pointLightingSpecularColorUniform, 0.8, 0.8, 0.8)
	gl.uniform3f(shaderProgram.pointLightingDiffuseColorUniform, 0.8, 0.8, 0.8)
	gl.uniform1i(shaderProgram.useTexturesUniform, true)
	mat4.identity(mvMatrix)
	mat4.translate(mvMatrix, [0, 0, -60])
	mat4.rotate(mvMatrix, degToRad(120), [1, 0, -1])
	
	mat4.multiply(camera.getViewMatrix(), mvMatrix, mvMatrix)

	gl.activeTexture(gl.TEXTURE0)
	if texture is "earth"
		gl.bindTexture(gl.TEXTURE_2D, textures.earth)
	else if texture is "metal"
		gl.bindTexture(gl.TEXTURE_2D, textures.metal)
	gl.uniform1i(shaderProgram.samplerUniform, 0)
	gl.uniform1f(shaderProgram.materialShininessUniform, 32.0)
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexPositionBuffer)
	gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, buffers.vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
	
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexTextureCoordBuffer)
	gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, buffers.vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0)
	
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexNormalBuffer)
	gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute, buffers.vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0)

	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers.vertexIndexBuffer)
	setMatrixUniforms()
	gl.drawElements(gl.TRIANGLES, buffers.vertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0)

initializeGL = (canvas) ->
	try
		gl = canvas.getContext("experimental-webgl")
		gl.viewportWidth = canvas.width
		gl.viewportHeight = canvas.height
	if gl
		return gl
	else
		failure("Could not initialize WebGL.", gl)
		return null

getShader = (url, type) ->
	shader = null
	httpRequest = new XMLHttpRequest()
	httpRequest.addEventListener(
		"readystatechange"
		() ->
			return null if httpRequest.readyState isnt 4
			if httpRequest.status is 200
				shader = gl.createShader(type)
				gl.shaderSource(shader, httpRequest.responseText)
				gl.compileShader(shader)
				if not gl.getShaderParameter(shader, gl.COMPILE_STATUS)
					failure("A shader would not compile.", gl.getShaderInfoLog(shader))
					return null
			else
				failure("A shader could not be downloaded.")
				return null
	)
	# used synchronously
	httpRequest.open("GET", url, false)
	httpRequest.send()
	# shader has now been set
	return shader

getInitializedShaderProgram = () ->
	fragmentShader = getShader("shaders/blinn_phong.frag", gl.FRAGMENT_SHADER)
	vertexShader = getShader("shaders/blinn_phong.vert", gl.VERTEX_SHADER)
	program = gl.createProgram()
	gl.attachShader(program, vertexShader)
	gl.attachShader(program, fragmentShader)
	gl.linkProgram(program)
	if not gl.getProgramParameter(program, gl.LINK_STATUS)
		failure("Could not link a program.")
		return null
	gl.useProgram(program)
	program.vertexPositionAttribute = gl.getAttribLocation(program, "aVertexPosition")
	gl.enableVertexAttribArray(program.vertexPositionAttribute)
	program.vertexNormalAttribute = gl.getAttribLocation(program, "aVertexNormal")
	gl.enableVertexAttribArray(program.vertexNormalAttribute)
	program.textureCoordAttribute = gl.getAttribLocation(program, "aTextureCoord")
	gl.enableVertexAttribArray(program.textureCoordAttribute)
	program.pMatrixUniform = gl.getUniformLocation(program, "uPMatrix")
	program.mvMatrixUniform = gl.getUniformLocation(program, "uMVMatrix")
	program.nMatrixUniform = gl.getUniformLocation(program, "uNMatrix")
	program.samplerUniform = gl.getUniformLocation(program, "uSampler")
	program.materialShininessUniform = gl.getUniformLocation(program, "uMaterialShininess")
	program.useTexturesUniform = gl.getUniformLocation(program, "uUseTextures")
	program.ambientColorUniform = gl.getUniformLocation(program, "uAmbientColor")
	program.pointLightingLocationUniform = gl.getUniformLocation(program, "uPointLightingLocation")
	program.pointLightingSpecularColorUniform = gl.getUniformLocation(program, "uPointLightingSpecularColor")
	program.pointLightingDiffuseColorUniform = gl.getUniformLocation(program, "uPointLightingDiffuseColor")
	return program

# asynchronously loads image
initializeTexture = (url, callback) ->
	texture = gl.createTexture()
	texture.image = new Image()
	texture.image.onload = () ->
		gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
		gl.generateMipmap(gl.TEXTURE_2D);
		gl.bindTexture(gl.TEXTURE_2D, null);
		callback()
	texture.image.src = url
	return texture

failure = (params...) ->
	console.log("Xylem Failure: ")
	console.log(param) for param in params




