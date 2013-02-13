class Xylem

    constructor: (canvas)->
        @glContext = null
        @camera = null
        @sceneGraph = null
        @glContext = null

    initializeGL: ()->
    try
        @glContext = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
        @glContext.viewportWidth = canvas.width
        @glContext.viewportHeight = canvas.height
        @glContext.enable(@glContext.CULL_FACE)
        @glContext.cullFace(@glContext.BACK)
        @glContext.clearColor(0.0, 0.0, 0.0, 1.0)
        @glContext.disable(@glContext.BLEND)
        @glContext.enable(@glContext.DEPTH_TEST)
        @glContext.depthFunc(@glContext.LEQUAL)
        @glContext.viewport(0, 0, @glContext.viewportWidth, @glContext.viewportHeight)
    if not @glContext
        throw "Could not initialize WebGL."

    loadScene: (finishedCallback)->
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
            (resourceMap, success)->
                if not success
                    throw "Not all necessary resources could be loaded."
                teapotModel = new Model(@glContext)
                teapotModel.loadModel(resourceMap["teapot_json"])
                metalTexture = new Texture(@glContext, resourceMap["metal_texture"])
                teapotModel.setTexture(metalTexture)
                teapot = new SceneObject()
                teapot.setModel(teapotModel)
                teapot.translate([1.5, 0.0, 0.0])
                teapot.scale([0.1, 0.1, 0.1])

                boxModel = new Model(@glContext)
                boxModel.loadModel(resourceMap["cube_json"])
                box = new SceneObject()
                box.setModel(boxModel)
                box.translate([-1.5, 0.0, 0.0])

                graph = new SceneGraph()
                root = new SceneNode()
                root.addChild(teapot)
                root.addChild(box)
                graph.setRoot(root)
                
                @initialShaderProgram = new ShaderProgram(@glContext)
                @initialShaderProgram.compileShader(resourceMap["frag_shader"], @glContext.FRAGMENT_SHADER)
                @initialShaderProgram.compileShader(resourceMap["vert_shader"], @glContext.VERTEX_SHADER)

                @initialShaderProgram.setUniform3f("pointLightingDiffuseColor", [0.8, 0.8, 0.8])
                @initialShaderProgram.setUniform3f("pointLightingSpecularColor", [0.8, 0.8, 0.8])
                @initialShaderProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
                @initialShaderProgram.setUniform3f("pointLightingLocation", [0.0, 20.0, 3.0])
                @initialShaderProgram.setUniform1f("specularHardness", 32.0)

                finishedCallback()
        )

    draw: ()->
        @glContext.clear(@glContext.COLOR_BUFFER_BIT | @glContext.DEPTH_BUFFER_BIT)
        @initialShaderProgram.enableProgram()
        @sceneGraph.draw(@initialShaderProgram, @camera)

    mainLoop: ()->
        this.draw()
        browserVersionOf("requestAnimationFrame")(this.mainLoop())