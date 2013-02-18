class Xylem

    constructor: (canvas)->
        @glContext = null
        @camera = null
        @sceneGraph = null
        @glContext = this.initializeGL(canvas)

    initializeGL: (canvas)->
        gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        #gl.enable(gl.CULL_FACE)
        #gl.cullFace(gl.BACK)
        gl.clearColor(0.0, 0.0, 0.0, 1.0)
        gl.disable(gl.BLEND)
        gl.enable(gl.DEPTH_TEST)
        gl.depthFunc(gl.LEQUAL)
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
        if not gl
            throw "Could not initialize WebGL."
        else
            return gl

    loadScene: (callback)->
        rl = new ResourceLoader(
            [
                {
                    "name" : "metal_texture",
                    "url" : "textures/metal.jpg",
                    "type" : "image"
                }, {
                    "name" : "frag_shader",
                    "url" : "shaders/blinn_phong.frag.glsl",
                    "type" : "text"
                }, {
                    "name" : "vert_shader",
                    "url" : "shaders/blinn_phong.vert.glsl",
                    "type" : "text"
                }, {
                    "name" : "teapot_json",
                    "url" : "models/teapot.model.json",
                    "type" : "json"
                }, {
                    "name" : "cube_json",
                    "url" : "models/cornell.model.json",
                    "type" : "json"
                }
            ],
            (resourceMap, success)=>
                if not success
                    throw "Not all necessary resources could be loaded."

                @camera = new SceneCamera()
                @camera.setProperties(90, @glContext.viewportWidth, @glContext.viewportHeight, 0.1, 100)
                @camera.translate([0,0,6.0])

                teapotModel = new Model(@glContext)
                teapotModel.loadModel(resourceMap["teapot_json"])
                metalTexture = new Texture(@glContext, resourceMap["metal_texture"])
                teapot = new SceneObject()
                teapot.setModel(teapotModel)
                teapot.setTexture(metalTexture)
                teapot.translate([0.0, -3.2, -3.5])
                teapot.scale([0.3, 0.3, 0.3])

                boxModel = new Model(@glContext)
                boxModel.loadModel(resourceMap["cube_json"])
                box = new SceneObject()
                box.setModel(boxModel)
                box.translate([0.0, 0.0, 0.0])
                box.scale([6.0, 6.0, 6.0])

                @sceneGraph = new SceneGraph()
                root = new SceneNode()
                root.addChild(teapot)
                root.addChild(box)
                @sceneGraph.setRoot(root)
                
                @initialShaderProgram = new ShaderProgram(@glContext)
                @initialShaderProgram.compileShader(resourceMap["frag_shader"], @glContext.FRAGMENT_SHADER)
                @initialShaderProgram.compileShader(resourceMap["vert_shader"], @glContext.VERTEX_SHADER)
                @initialShaderProgram.enableProgram()
                @initialShaderProgram.setUniform3f("pointLightingDiffuseColor", [0.8, 0.8, 0.8])
                @initialShaderProgram.setUniform3f("pointLightingSpecularColor", [0.8, 0.8, 0.8])
                @initialShaderProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
                @initialShaderProgram.setUniform3f("pointLightingLocation", [-4, 4, -4])
                @initialShaderProgram.setUniform1f("specularHardness", 32.0)

                callback()
        )
    
    draw: ()->
        @glContext.clear(@glContext.COLOR_BUFFER_BIT | @glContext.DEPTH_BUFFER_BIT)
        @sceneGraph.draw(@initialShaderProgram, @camera)

    mainLoop: ()->
        this.draw()
        browserVersionOf("requestAnimationFrame")(()=>this.mainLoop())

window.Xylem = Xylem