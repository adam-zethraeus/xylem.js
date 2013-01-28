window.onload = () ->
	xylem()

gl = null
camera = null

xylem = () ->
	canvas = document.getElementById("render_canvas")
	gl = initializeGL(canvas)
	teapotModel = new Model(gl)
	teapotModel.loadBuffers(teapotModel.loadJSON("models/teapot.json"))
	camera = new Camera()
	camera.setProperties(20, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
	camera.translate([0,0,20])
	camera.rotate(5, [0, 1, 0])
	gl.clearColor(0.0, 0.0, 0.0, 1.0)
	gl.enable(gl.DEPTH_TEST)
	textureImage = new Image()
	textureImage.onload = () ->
		metalTexture = new Texture(gl, textureImage)
		teapotModel.setTexture(metalTexture)
		teapot = new SceneObject(teapotModel)
		teapot.translate([0, 0, -60])
		sp = new ShaderProgram(gl)
		frag = sp.getShaderText("shaders/blinn_phong.frag")
		vert = sp.getShaderText("shaders/blinn_phong.vert")
		sp.compileShader(frag, gl.FRAGMENT_SHADER)
		sp.compileShader(vert, gl.VERTEX_SHADER)
		sp.enableProgram()
		draw(teapot, sp)
	textureImage.src = "textures/metal.jpg"

draw = (sceneObject, shaderProgram) ->
	browserVersionOf("requestAnimationFrame")(()->draw(sceneObject, shaderProgram))
	mvMatrix = mat4.create()
	sceneObject.rotate(degToRad(5), [1, 0, -1])
	
	mat4.multiply(camera.getViewMatrix(), sceneObject.getModelMatrix(), mvMatrix)

	gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	
	shaderProgram.setUniform3f("pointLightingDiffuseColor", [0.8, 0.8, 0.8])
	shaderProgram.setUniform1i("useTextures", 1);
	shaderProgram.setUniform3f("pointLightingSpecularColor", [0.8, 0.8, 0.8])
	shaderProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
	shaderProgram.setUniform3f("pointLightingLocation", [-10.0, 4.0, -20.0])
	shaderProgram.setUniform1f("materialShininess", 32.0)
	shaderProgram.setUniform1i("sampler", 0)

	shaderProgram.setUniformMatrix4fv("pMatrix", camera.getProjectionMatrix())
	shaderProgram.setUniformMatrix4fv("mvMatrix", mvMatrix)
	normalMatrix = mat3.create()
	mat4.toInverseMat3(mvMatrix, normalMatrix)
	mat3.transpose(normalMatrix)
	shaderProgram.setUniformMatrix3fv("nMatrix", normalMatrix)
	
	sceneObject.draw(shaderProgram)

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
