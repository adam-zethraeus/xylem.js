window.onload = () ->
    rl = new ResourceLoader(
        [
            {
                "name": "metal_texture",
                "url": "models/teapot/texture.jpg",
                "type": "image"
            }, {
                "name": "frag_shader",
                "url": "shaders/blinn_phong.frag",
                "type": "text"
            }, {
                "name": "vert_shader",
                "url": "shaders/blinn_phong.vert",
                "type": "text"
            }, {
                "name": "teapot_json",
                "url": "models/teapot/model.json",
                "type": "json"
            }
        ],
        (resourceMap, success)->xylem(resourceMap, success)
    )

gl = null
camera = null

xylem = (resourceMap, success) ->
    if not success
        throw "Not all necessary resources could be loaded."
    canvas = document.getElementById("render_canvas")
    gl = initializeGL(canvas)
    teapotModel = new Model(gl)
    teapotModel.loadBuffers(resourceMap["teapot_json"])
    camera = new SceneCamera()
    camera.setProperties(20, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
    camera.translate([0,0,20])
    camera.rotate(5, [0, 1, 0])
    gl.clearColor(0.0, 0.0, 0.0, 1.0)
    gl.disable(gl.BLEND)
    gl.enable(gl.DEPTH_TEST)
    gl.depthFunc(gl.LEQUAL)
    gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT)
    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
    metalTexture = new Texture(gl, resourceMap["metal_texture"])
    teapotModel.setTexture(metalTexture)
    teapot = new SceneObject()
    teapot.setModel(teapotModel)
    teapot.translate([0, 0, -60])
    childpot = new SceneObject()
    childpot.setModel(teapotModel)
    childpot.translate([0, 3, 0])
    childpot.scale([0.9, 0.9, 0.9])
    teapot.addChild(childpot)
    graph = new SceneGraph()
    graph.setRoot(teapot)
    
    shaderProgram = new ShaderProgram(gl)
    shaderProgram.compileShader(resourceMap["frag_shader"], gl.FRAGMENT_SHADER)
    shaderProgram.compileShader(resourceMap["vert_shader"], gl.VERTEX_SHADER)
    shaderProgram.enableProgram()

    shaderProgram.setUniform3f("pointLightingDiffuseColor", [0.8, 0.8, 0.8])
    shaderProgram.setUniform1i("useTextures", 1);
    shaderProgram.setUniform3f("pointLightingSpecularColor", [0.8, 0.8, 0.8])
    shaderProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
    shaderProgram.setUniform3f("pointLightingLocation", [-10.0, 4.0, -20.0])
    shaderProgram.setUniform1f("materialShininess", 32.0)
    shaderProgram.setUniform1i("sampler", 0)

    draw(graph, shaderProgram)

draw = (sceneGraph, shaderProgram) ->
    browserVersionOf("requestAnimationFrame")(()->draw(sceneGraph, shaderProgram))
    sceneGraph.rootNode.rotate(degToRad(5), [1, 0, -1])

    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    sceneGraph.draw(shaderProgram, camera)

initializeGL = (canvas) ->
    try
        gl = canvas.getContext("experimental-webgl")
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        gl.enable(gl.CULL_FACE)
        gl.cullFace(gl.BACK)
    if gl
        return gl
    else
        throw "Could not initialize WebGL."
        return null

degToRad = (degrees) ->
    return degrees * (Math.PI / 180);
