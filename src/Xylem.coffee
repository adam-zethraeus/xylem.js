class Xylem

    constructor: (canvas)->
        @gl = null
        @sceneGraph = null
        @gl = @initializeGL(canvas)
        @gBuffer = new GBuffer(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])
        @buffers = [new Texture(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])
                    new Texture(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])]
        @currBuffer = 0
        @screenQuad = new FullscreenQuad(@gl)

    initializeGL: (canvas)->
        gl = canvas.getContext("webgl") or canvas.getContext("experimental-webgl")
        gl or throw "Could not initialize WebGL."
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        gl.enable(gl.CULL_FACE)
        gl.cullFace(gl.BACK)
        gl.clearColor(0.0, 0.0, 0.0, 1.0)
        gl.disable(gl.BLEND)
        gl.enable(gl.DEPTH_TEST)
        gl.depthFunc(gl.LEQUAL)
        gl.getExtension('OES_texture_float') or throw "No floating point texture support."
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
        return gl

    loadScene: (scene, callback)->
        @loadSceneResources(
            scene,
            (map, success)=>
                @setUpScene(scene, map, success, callback)
        )

    loadSceneResources: (scene, callback)->
        rl = new ResourceLoader()
        rl.load(
            scene.resources,
            callback
        )

    setUpScene: (scene, @resourceMap, loadSuccessful, callback)->
        if not loadSuccessful
            throw "Not all necessary resources could be loaded."
        @sceneGraph = new SceneGraph()

        objTraverse = (parentNode, obj)=>
            type = getOrThrow(obj, "type")
            node = null
            if type is "object"
                node = new SceneObject()
                model = new Model(@gl)
                model.loadModel(@resourceMap[getOrThrow(obj, "model")])
                node.setModel(model)
                if obj.texture?
                    node.setTexture(new Texture.fromImage(@gl, @resourceMap[obj.texture]))
                if obj.scale?
                    node.scale(obj.scale)
            else if type is "light"
                node = new SceneLight()
                node.setAmbientColor(getOrThrow(obj, "ambientColor"))
                node.setDiffuseColor(getOrThrow(obj, "diffuseColor"))
                node.setSpecularColor(getOrThrow(obj, "specularColor"))
                node.setSpecularHardness(getOrThrow(obj, "specularHardness"))
            else if type is "camera"
                node = new SceneCamera()
                node.setProperties(
                    degreesToRadians(getOrThrow(obj, "fieldOfViewAngle")),
                    @gl.viewportWidth,
                    @gl.viewportHeight,
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

        callback()
    
    draw: ()->
        @gBuffer.populate((x)=>@sceneGraph.draw(x))
        @gBuffer.albedoTexture.bind(0)
        @albedoProgram = new ShaderProgram(@gl)
        @albedoProgram.compileShader(window.XylemShaders.albedoFromGbuffer.f, @gl.FRAGMENT_SHADER)
        @albedoProgram.compileShader(window.XylemShaders.albedoFromGbuffer.v, @gl.VERTEX_SHADER)
        @albedoProgram.linkProgram()
        @albedoProgram.enableProgram()
        @albedoProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
        @albedoProgram.enableAttribute("vertexPosition")
        @albedoProgram.enableAttribute("textureCoord")
        @albedoProgram.setUniform1i("albedos", 0)
        @buffers[@currBuffer].drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT)
                @screenQuad.draw(@albedoProgram)
            false
        )
        @albedoProgram.disableAttribute("vertexPosition")
        @albedoProgram.disableAttribute("textureCoord")


        @gBuffer.normalsTexture.bind(0)
        @gBuffer.albedoTexture.bind(1)
        @gBuffer.positionTexture.bind(2)
        @lightingProgram = new ShaderProgram(@gl)
        @lightingProgram.compileShader(window.XylemShaders.lightOverGbuffer.f , @gl.FRAGMENT_SHADER)
        @lightingProgram.compileShader(window.XylemShaders.lightOverGbuffer.v, @gl.VERTEX_SHADER)
        @lightingProgram.linkProgram()
        @lightingProgram.enableProgram()
        camera = @sceneGraph.getNodesOfType(SceneCamera)[0]
        lights = @sceneGraph.getNodesOfType(SceneLight)
        origin = vec4.fromValues(0, 0, 0, 1)
        @lightingProgram.enableAttribute("vertexPosition")
        @lightingProgram.enableAttribute("textureCoord")
        @lightingProgram.setUniform1i("normals", 0)
        @lightingProgram.setUniform1i("albedos", 1)
        @lightingProgram.setUniform1i("positions", 2)
        @gl.enable(@gl.BLEND)
        @gl.disable(@gl.DEPTH_TEST)
        @gl.blendFunc(@gl.ONE, @gl.ONE)
        for light in lights
            pos = vec4.create()
            lightMVMatrix = mat4.create()
            mat4.multiply(lightMVMatrix, camera.getCumulativeViewMatrix(), light.getCumulativeModelMatrix())
            vec4.transformMat4(pos, origin, lightMVMatrix)
            light.setUniforms(@lightingProgram, [pos[0], pos[1], pos[2]])
            @buffers[@currBuffer].drawTo(
                ()=>
                    @screenQuad.draw(@lightingProgram)
                false
            )
        @gl.enable(@gl.DEPTH_TEST)
        @gl.disable(@gl.BLEND)
        @lightingProgram.disableAttribute("vertexPosition")
        @lightingProgram.disableAttribute("textureCoord")

        @screenQuad.drawWithTexture(@buffers[@currBuffer])


    mainLoop: ()->
        @draw()
        browserVersionOf("requestAnimationFrame")(()=>@mainLoop())

window.Xylem = Xylem
