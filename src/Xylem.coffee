class Xylem

    constructor: (canvas)->
        @gl = null
        @sceneGraph = null
        @gl = @initializeGL(canvas)

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

        @initialShaderProgram = new ShaderProgram(@gl)
        @initialShaderProgram.compileShader(@resourceMap[getOrThrow(scene.shaders, "fragment")], @gl.FRAGMENT_SHADER)
        @initialShaderProgram.compileShader(@resourceMap[getOrThrow(scene.shaders, "vertex")], @gl.VERTEX_SHADER)
        @initialShaderProgram.enableProgram()

        callback()
    
    draw: ()->
        t = new Texture(@gl, 1024, 1024)
        t.drawTo(
            ()=>
                @initialShaderProgram.enableAttribute("vertexPosition")
                @initialShaderProgram.enableAttribute("vertexNormal")
                @initialShaderProgram.enableAttribute("vertexColor")
                @initialShaderProgram.enableAttribute("textureCoord")
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
                @sceneGraph.draw(@initialShaderProgram)
                @initialShaderProgram.disableAttribute("vertexPosition")
                @initialShaderProgram.disableAttribute("vertexNormal")
                @initialShaderProgram.disableAttribute("vertexColor")
                @initialShaderProgram.disableAttribute("textureCoord")
            true
        )
        f = new FullscreenQuad(@gl)
        s = new ShaderProgram(@gl)
        s.compileShader(@resourceMap["blit_frag"], @gl.FRAGMENT_SHADER)
        s.compileShader(@resourceMap["blit_vert"], @gl.VERTEX_SHADER)
        s.enableProgram()
        s.enableAttribute("vertexPosition")
        s.enableAttribute("textureCoord")
        t.bind(0)
        s.setUniform1i("sampler", 0)
        f.draw(s)
        s.disableAttribute("vertexPosition")
        s.disableAttribute("textureCoord")

    mainLoop: ()->
        @draw()
        browserVersionOf("requestAnimationFrame")(()=>@mainLoop())

window.Xylem = Xylem