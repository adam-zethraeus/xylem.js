window.onload = () ->
	xylem()

gl = null
camera = null

xylem = () ->
	canvas = document.getElementById("render_canvas")
	gl = initializeGL(canvas)
	teapot = new Model(gl)
	teapot.loadBuffers(teapot.loadJSON("models/teapot.json"))
	camera = new Camera()
	camera.setProperties(20, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
	camera.translate([0,0,20])
	camera.rotate(5, [0, 1, 0])
	gl.clearColor(0.0, 0.0, 0.0, 1.0)
	gl.enable(gl.DEPTH_TEST)
	textureImage = new Image()
	textureImage.onload = () ->
		metalTexture = new Texture(gl, textureImage)
		teapot.setTexture(metalTexture)
		sp = new ShaderProgram(gl)
		frag = sp.getShaderText("shaders/blinn_phong.frag")
		vert = sp.getShaderText("shaders/blinn_phong.vert")
		sp.compileShader(frag, gl.FRAGMENT_SHADER)
		sp.compileShader(vert, gl.VERTEX_SHADER)
		sp.enableProgram()
		draw(teapot, sp, 0)
	textureImage.src = "textures/metal.jpg"

draw = (model, shaderProgram, rotate) ->
	browserVersionOf("requestAnimationFrame")(()->draw(model, shaderProgram, ++rotate))
	mvMatrix = mat4.create()
	mat4.identity(mvMatrix)
	mat4.translate(mvMatrix, [0, 0, -60])
	mat4.rotate(mvMatrix, degToRad(120 + rotate), [1, 0, -1])
	
	mat4.multiply(camera.getViewMatrix(), mvMatrix, mvMatrix)

	gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	
	shaderProgram.setUniform3f("uPointLightingDiffuseColor", [0.8, 0.8, 0.8])
	shaderProgram.setUniform1i("uUseTextures", 1);
	shaderProgram.setUniform3f("uPointLightingSpecularColor", [0.8, 0.8, 0.8])
	shaderProgram.setUniform3f("uAmbientColor", [0.2, 0.2, 0.2])
	shaderProgram.setUniform3f("uPointLightingLocation", [-10.0, 4.0, -20.0])
	shaderProgram.setUniform1f("uMaterialShininess", 32.0)
	shaderProgram.setUniform1i("uSampler", 0)

	shaderProgram.setUniformMatrix4fv("uPMatrix", camera.getProjectionMatrix())
	shaderProgram.setUniformMatrix4fv("uMVMatrix", mvMatrix)
	normalMatrix = mat3.create()
	mat4.toInverseMat3(mvMatrix, normalMatrix)
	mat3.transpose(normalMatrix)
	shaderProgram.setUniformMatrix3fv("uNMatrix", normalMatrix)
	
	model.draw(shaderProgram, true)

initializeGL = (canvas) ->
	try
		gl = canvas.getContext("experimental-webgl")
		gl.viewportWidth = canvas.width
		gl.viewportHeight = canvas.height
	if gl
		return gl
	else
		throw "Could not initialize WebGL."
		return null

degToRad = (degrees) ->
	return degrees * (Math.PI / 180);
