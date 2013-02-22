class SceneGraph
    constructor: ()->
        @rootNode = null

    setRoot: (@rootNode)->

    getRoot: ()->
        return @rootNode

    getNodesOfType: (type)->
        list = []
        preOrder = (node, type) ->
            if node instanceof type
                list.push(node)
            for child in node.children
                preOrder(child, type)
        preOrder(@rootNode, type)
        return list

    actOnNodesOfType: (type, act)->
        preOrder = (node, type, act) ->
            if node instanceof type
                act(node)
            for child in node.children
                preOrder(child, type, act)
        preOrder(@rootNode, type, act)

    draw: (shaderProgram)->
        startingModelMatrix = mat4.create()
        mat4.identity(startingModelMatrix)
        @rootNode.accumulateModelMatrix(startingModelMatrix)
        camera = @getNodesOfType(SceneCamera)[0]
        light = @getNodesOfType(SceneLight)[0]
        origin = vec4.fromValues(0, 0, 0, 1)
        pos = vec4.create()
        lightMvMatrix = mat4.create()
        mat4.multiply(lightMvMatrix, camera.getCumulativeViewMatrix(), light.getCumulativeModelMatrix())
        vec4.transformMat4(pos, origin, lightMvMatrix)
        #vPosition = mvMatrix * vec4(vertexPosition, 1.0);
        light.setUniforms(shaderProgram, [pos[0], pos[1], pos[2]])
        @actOnNodesOfType(SceneObject, (object)->
            mvMatrix = mat4.create()
            mat4.multiply(mvMatrix, camera.getCumulativeViewMatrix(), object.getCumulativeModelMatrix())
            shaderProgram.setUniformMatrix4fv("mvMatrix", mvMatrix)
            shaderProgram.setUniformMatrix4fv("pMatrix", camera.getProjectionMatrix())
            normalMatrix = mat3.create()
            mat3.fromMat4(normalMatrix, mvMatrix)
            mat3.invert(normalMatrix, normalMatrix)
            mat3.transpose(normalMatrix, normalMatrix)
            shaderProgram.setUniformMatrix3fv("nMatrix", normalMatrix)
            object.getGraphicalModel().draw(shaderProgram, object.getTexture())
        )
