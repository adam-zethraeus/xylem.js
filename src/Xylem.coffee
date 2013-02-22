class Xylem

    constructor: (canvas)->
        @glContext = null
        @sceneGraph = null
        @glContext = this.initializeGL(canvas)

    initializeGL: (canvas)->
        gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        gl.enable(gl.CULL_FACE)
        gl.cullFace(gl.BACK)
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

        objTraverse = (parentNode, obj)=>
            type = getOrThrow(obj, "type")
            node = null
            if type is "object"
                node = new SceneObject()
                model = new Model(@glContext)
                model.loadModel(resourceMap[getOrThrow(obj, "model")])
                node.setModel(model)
                if obj.texture?
                    node.setTexture(new Texture(@glContext, resourceMap[obj.texture]))
                if obj.scale?
                    node.scale(obj.scale)
            else if type is "light"
                node = new SceneLight()
                node.setAmbientColour(getOrThrow(obj, "ambientColour"))
                node.setDiffuseColour(getOrThrow(obj, "diffuseColour"))
                node.setSpecularColour(getOrThrow(obj, "specularColour"))
                node.setSpecularHardness(getOrThrow(obj, "specularHardness"))
            else if type is "camera"
                node = new SceneCamera()
                node.setProperties(
                    degreesToRadians(getOrThrow(obj, "fieldOfViewAngle")),
                    @glContext.viewportWidth,
                    @glContext.viewportHeight,
                    getOrThrow(obj, "nearPlaneDistance"),
                    getOrThrow(obj, "farPlaneDistance")
                )
            else
                throw "A node of an unsupported or unmarked type was found."
            parentNode.addChild(node)
            if obj.translate?
                node.translate(obj.translate)
            if obj.rotation?
                node.rotate(degreesToRadians(getOrThrow(obj.rotation, "degrees")), getOrThrow(obj.rotation, "axis"))
            if obj.children?
                for childObj in obj.children
                    objTraverse(node, childObj)
        
        @sceneGraph.setRoot(new SceneNode())
        objs = getOrThrow(scene, "tree")
        for obj in objs
            objTraverse(@sceneGraph.getRoot(), obj)

        @initialShaderProgram = new ShaderProgram(@glContext)

        @initialShaderProgram.compileShader(resourceMap[getOrThrow(scene.shaders, "fragment")], @glContext.FRAGMENT_SHADER)
        @initialShaderProgram.compileShader(resourceMap[getOrThrow(scene.shaders, "vertex")], @glContext.VERTEX_SHADER)
        @initialShaderProgram.enableProgram()

        callback()
    
    draw: ()->
        @glContext.clear(@glContext.COLOR_BUFFER_BIT | @glContext.DEPTH_BUFFER_BIT)
        @sceneGraph.draw(@initialShaderProgram)

    mainLoop: ()->
        this.draw()
        browserVersionOf("requestAnimationFrame")(()=>this.mainLoop())

window.Xylem = Xylem