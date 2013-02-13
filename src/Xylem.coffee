window.onload = ()->
    rl = new ResourceLoader(
        [
            {
                "name" : "metal_texture",
                "url" : "textures/metal.jpg",
                "type" : "image"
            }, {
                "name" : "frag_shader",
                "url" : "shaders/blinn_phong.frag",
                "type" : "text"
            }, {
                "name" : "vert_shader",
                "url" : "shaders/blinn_phong.vert",
                "type" : "text"
            }, {
                "name" : "teapot_json",
                "url" : "models/teapot.json",
                "type" : "json"
            }, {
                "name" : "cube_json",
                "url" : "models/cube.json",
                "type" : "json"
            }
        ],
        (resourceMap, success)-> xylem(resourceMap, success)
    )

gl = null
camera = null

xylem = (resourceMap, success)->
    if not success
        throw "Not all necessary resources could be loaded."
    canvas = document.getElementById("render_canvas")
    gl = initializeGL(canvas)
    camera = new SceneCamera()
    camera.setProperties(90, gl.viewportWidth, gl.viewportHeight, 0.1, 100)
    camera.translate([0,0,5])
    gl.clearColor(0.0, 0.0, 0.0, 1.0)
    gl.disable(gl.BLEND)
    gl.enable(gl.DEPTH_TEST)
    gl.depthFunc(gl.LEQUAL)
    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)

    teapotModel = new Model(gl)
    teapotModel.loadModel(resourceMap["teapot_json"])
    metalTexture = new Texture(gl, resourceMap["metal_texture"])
    teapotModel.setTexture(metalTexture)
    teapot = new SceneObject()
    teapot.setModel(teapotModel)
    teapot.translate([1.5, 0.0, 0.0])
    teapot.scale([0.1, 0.1, 0.1])

    boxModel = new Model(gl)
    boxModel.loadModel(resourceMap["cube_json"])
    box = new SceneObject()
    box.setModel(boxModel)
    box.translate([-1.5, 0.0, 0.0])

    graph = new SceneGraph()
    root = new SceneNode()
    root.addChild(teapot)
    root.addChild(box)
    graph.setRoot(root)
    
    shaderProgram = new ShaderProgram(gl)
    shaderProgram.compileShader(resourceMap["frag_shader"], gl.FRAGMENT_SHADER)
    shaderProgram.compileShader(resourceMap["vert_shader"], gl.VERTEX_SHADER)
    shaderProgram.enableProgram()

    shaderProgram.setUniform3f("pointLightingDiffuseColor", [0.8, 0.8, 0.8])
    shaderProgram.setUniform3f("pointLightingSpecularColor", [0.8, 0.8, 0.8])
    shaderProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
    shaderProgram.setUniform3f("pointLightingLocation", [0.0, 20.0, 3.0])
    shaderProgram.setUniform1f("specularHardness", 32.0)

    draw(graph, shaderProgram)

draw = (sceneGraph, shaderProgram)->
    browserVersionOf("requestAnimationFrame")(() -> draw(sceneGraph, shaderProgram))
    sceneGraph.rootNode.rotate(degreesToRadians(2), [0.0, 1.0, 0.0])
    sceneGraph.rootNode.rotate(degreesToRadians(1), [1.0, 0.0, -1.0])

    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    sceneGraph.draw(shaderProgram, camera)

initializeGL = (canvas)->
    try
        gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        gl.enable(gl.CULL_FACE)
        gl.cullFace(gl.BACK)
    if gl
        return gl
    else
        throw "Could not initialize WebGL."
