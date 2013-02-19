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

    loadScene: (scene, callback)->
        this.loadSceneResources(
            scene,
            (map, success)=>
                this.setUpScene(scene, map, success, callback)
        )

    loadSceneResources: (scene, callback)->
        rl = new ResourceLoader()
        rl.load(
            scene.resources,
            callback
        )

    setUpScene: (scene, resourceMap, loadSuccessful, callback)->
        if not loadSuccessful
            throw "Not all necessary resources could be loaded."
        @sceneGraph = new SceneGraph()

        # Set up camera.
        cam = getOrThrow(scene.cameras, 0)
        @camera = new SceneCamera()
        @camera.setProperties(
            getOrThrow(cam, "fieldOfViewAngle"),
            @glContext.viewportWidth,
            @glContext.viewportHeight,
            getOrThrow(cam, "nearPlaneDistance"),
            getOrThrow(cam, "farPlaneDistance")
        )
        @camera.translate(getOrThrow(cam, "location"))
        # TODO: Use camera look.

        objTraverse = (parentNode, obj)=>
            node = new SceneObject()
            parentNode.addChild(node)
            model = new Model(@glContext)
            model.loadModel(resourceMap[getOrThrow(obj, "model")])
            node.setModel(model)
            if obj.texture?
                node.setTexture(new Texture(@glContext, resourceMap[obj.texture]))
            if obj.location?
                node.translate(obj.location)
            if obj.scale?
                node.scale(obj.scale)
            if obj.rotation?
                node.rotate(obj.rotation)
            if obj.children?
                for childObj in obj.children
                    objTraverse(node, childObj)
        
        @sceneGraph.setRoot(new SceneNode())
        objs = getOrThrow(scene, "objects")
        for obj in objs
            objTraverse(@sceneGraph.getRoot(), obj)

        @initialShaderProgram = new ShaderProgram(@glContext)

        @initialShaderProgram.compileShader(resourceMap[getOrThrow(scene.shaders, "fragment")], @glContext.FRAGMENT_SHADER)
        @initialShaderProgram.compileShader(resourceMap[getOrThrow(scene.shaders, "vertex")], @glContext.VERTEX_SHADER)
        @initialShaderProgram.enableProgram()

        light = getOrThrow(scene.lights, 0)
        @initialShaderProgram.setUniform3f("pointLightingDiffuseColor", getOrThrow(light, "diffuseColour"))
        @initialShaderProgram.setUniform3f("pointLightingSpecularColor", getOrThrow(light, "specularColour"))
        @initialShaderProgram.setUniform3f("ambientColor", getOrThrow(light, "ambientColour"))
        @initialShaderProgram.setUniform3f("pointLightingLocation", getOrThrow(light, "location"))
        @initialShaderProgram.setUniform1f("specularHardness", getOrThrow(light, "specularHardness"))

        callback()
    
    draw: ()->
        @glContext.clear(@glContext.COLOR_BUFFER_BIT | @glContext.DEPTH_BUFFER_BIT)
        @sceneGraph.draw(@initialShaderProgram, @camera)

    mainLoop: ()->
        this.draw()
        browserVersionOf("requestAnimationFrame")(()=>this.mainLoop())

window.Xylem = Xylem