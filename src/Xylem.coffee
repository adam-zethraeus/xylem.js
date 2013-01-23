window.onload = () ->
	xylem()

mvMatrix = mat4.create()
pMatrix = mat4.create()
gl = null
camera = null

xylem = () ->
	canvas = document.getElementById("render_canvas")
	gl = initializeGL(canvas)
	teapot = new Model(gl, "models/teapot.json")
	camera = new Camera()
	camera.setProperties(20, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
	pMatrix = camera.getProjectionMatrix()
	camera.translate([0,0,20])
	camera.rotate(5, [0, 1, 0])
	gl.clearColor(0.0, 0.0, 0.0, 1.0)
	gl.enable(gl.DEPTH_TEST)
	metalTexture = new Texture(gl)
	metalTexture.setImage("textures/metal.jpg", ()->
		sp = new ShaderProgram(gl)
		frag = sp.getShaderText("shaders/blinn_phong.frag")
		vert = sp.getShaderText("shaders/blinn_phong.vert")
		frag_comp = sp.compileShader(frag, gl.FRAGMENT_SHADER)
		vert_comp = sp.compileShader(vert, gl.VERTEX_SHADER)
		sp.enableProgram(vert_comp, frag_comp);
		draw(teapot.getBuffers(), metalTexture.getTexture(), sp.getProgram())
	)

draw = (buffers, glTexture, shaderProgram) ->
	mat4.identity(mvMatrix)
	mat4.translate(mvMatrix, [0, 0, -60])
	mat4.rotate(mvMatrix, degToRad(120), [1, 0, -1])
	
	mat4.multiply(camera.getViewMatrix(), mvMatrix, mvMatrix)

	gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.uniform3f(shaderProgram.ambientColorUniform, 0.2, 0.2, 0.2)
	gl.uniform3f(shaderProgram.pointLightingLocationUniform, -10.0, 4.0, -20.0)
	gl.uniform3f(shaderProgram.pointLightingSpecularColorUniform, 0.8, 0.8, 0.8)
	gl.uniform3f(shaderProgram.pointLightingDiffuseColorUniform, 0.8, 0.8, 0.8)
	gl.uniform1i(shaderProgram.useTexturesUniform, true)


	gl.activeTexture(gl.TEXTURE0)
	gl.bindTexture(gl.TEXTURE_2D, glTexture)
	gl.uniform1i(shaderProgram.samplerUniform, 0)
	gl.uniform1f(shaderProgram.materialShininessUniform, 32.0)
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexPositionBuffer)
	gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, buffers.vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
	
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexTextureCoordBuffer)
	gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, buffers.vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0)
	
	gl.bindBuffer(gl.ARRAY_BUFFER, buffers.vertexNormalBuffer)
	gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute, buffers.vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0)

	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers.vertexIndexBuffer)
	
	gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix)
	gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix)
	normalMatrix = mat3.create()
	mat4.toInverseMat3(mvMatrix, normalMatrix)
	mat3.transpose(normalMatrix)
	gl.uniformMatrix3fv(shaderProgram.nMatrixUniform, false, normalMatrix)

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

failure = (params...) ->
	console.log("Xylem Failure: ")
	console.log(param) for param in params

degToRad = (degrees) ->
	return degrees * (Math.PI / 180);
