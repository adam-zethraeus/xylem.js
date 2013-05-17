class Xylem

    constructor: (canvas)->
        @gl = null
        @sceneGraph = null
        @gl = @initializeGL(canvas)
        @setUpRendering(canvas)
        @screenQuad = new FullscreenQuad(@gl)

    initializeGL: (canvas)->
        gl = canvas.getContext("webgl") or canvas.getContext("experimental-webgl")
        gl or throw "Could not initialize WebGL."
        gl.viewportWidth = canvas.width
        gl.viewportHeight = canvas.height
        gl.enable(gl.CULL_FACE)
        gl.cullFace(gl.BACK)
        gl.clearColor(0.0, 0.0, 0.0, 1.0)
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
    
    setUpRendering: (canvas)->
        @gBuffer = new GBuffer(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])
        @buffers = [new Texture(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])
                    new Texture(@gl, [nextHighestPowerOfTwo(canvas.width), nextHighestPowerOfTwo(canvas.height)])]
        @currBuffer = 0

        @ambientProgram = new ShaderProgram(@gl)
        @ambientProgram.importShader("ambientPass_f")
        @ambientProgram.importShader("ambientPass_v")
        @ambientProgram.linkProgram()

        @pointLightingProgram = new ShaderProgram(@gl)
        @pointLightingProgram.importShader("pointLightPass_f")
        @pointLightingProgram.importShader("pointLightPass_v")
        @pointLightingProgram.linkProgram()

        @fxaaProgram = new ShaderProgram(@gl)
        @fxaaProgram.importShader("fxaaShader_f")
        @fxaaProgram.importShader("fxaaShader_v")
        @fxaaProgram.linkProgram()

    draw: ()->
        camera = @sceneGraph.getNodesOfType(SceneCamera)[0]
        lights = @sceneGraph.getNodesOfType(SceneLight)
        origin = vec4.fromValues(0, 0, 0, 1)
        @gl.enable(@gl.DEPTH_TEST)
        @gBuffer.populate((x)=>@sceneGraph.draw(x, camera))
        @gl.disable(@gl.DEPTH_TEST)
        @gBuffer.albedoTexture.bind(0)
        @ambientProgram.enableProgram()
        @ambientProgram.setUniform3f("ambientColor", [0.2, 0.2, 0.2])
        @ambientProgram.enableAttribute("vertexPosition")
        @ambientProgram.enableAttribute("textureCoord")
        @ambientProgram.setUniform1i("albedos", 0)
        @buffers[@currBuffer].drawTo(
            ()=>
                @gl.clear(@gl.COLOR_BUFFER_BIT)
                @screenQuad.draw(@ambientProgram)
            false
        )
        @ambientProgram.disableAttribute("vertexPosition")
        @ambientProgram.disableAttribute("textureCoord")

        @gBuffer.normalsDepthTexture.bind(0)
        @gBuffer.albedoTexture.bind(1)
        @pointLightingProgram.enableProgram()
        @pointLightingProgram.setUniform1f("farClip", camera.farClip);
        @pointLightingProgram.setUniformMatrix4fv("pMatrix", camera.getInverseProjectionMatrix())
        @pointLightingProgram.enableAttribute("vertexPosition")
        @pointLightingProgram.enableAttribute("textureCoord")
        @pointLightingProgram.setUniform1i("normals", 0)
        @pointLightingProgram.setUniform1i("albedos", 1)
        @gl.enable(@gl.BLEND)
        @gl.blendFunc(@gl.ONE, @gl.ONE)
        for light in lights
            pos = vec4.create()
            lightMVMatrix = mat4.create()
            mat4.multiply(lightMVMatrix, camera.getCumulativeViewMatrix(), light.getCumulativeModelMatrix())
            vec4.transformMat4(pos, origin, lightMVMatrix)
            light.setUniforms(@pointLightingProgram, [pos[0], pos[1], pos[2]])
            @buffers[@currBuffer].drawTo(
                ()=>
                    @screenQuad.draw(@pointLightingProgram)
                false
            )
        @gl.disable(@gl.BLEND)
        @pointLightingProgram.disableAttribute("vertexPosition")
        @pointLightingProgram.disableAttribute("textureCoord")

        @buffers[@currBuffer].bind(0)
        @fxaaProgram.enableProgram()
        @fxaaProgram.setUniform1i("tex", 0)
        @fxaaProgram.setUniform2f("viewportDimensions", [nextHighestPowerOfTwo(@gl.viewportWidth), nextHighestPowerOfTwo(@gl.viewportHeight)])
        @fxaaProgram.enableAttribute("vertexPosition")
        @fxaaProgram.enableAttribute("textureCoord")
        @currBuffer = @currBuffer ^ 1
        @buffers[@currBuffer].drawTo(
            ()=>
                @screenQuad.draw(@fxaaProgram)
            false
        )
        @fxaaProgram.disableAttribute("vertexPosition")
        @fxaaProgram.disableAttribute("textureCoord")

        @screenQuad.drawWithTexture(@buffers[@currBuffer])


    mainLoop: ()->
        @draw()
        browserVersionOf("requestAnimationFrame")(()=>@mainLoop())

window.Xylem = Xylem
