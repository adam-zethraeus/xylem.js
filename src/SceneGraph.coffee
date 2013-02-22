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

        camera = this.getNodesOfType(SceneCamera)[0]
        light = this.getNodesOfType(SceneLight)[0]
        light.setUniforms(shaderProgram, [0,0,0])
        this.actOnNodesOfType(SceneObject, (object)->
            mvMatrix = mat4.create()
            mat4.multiply(camera.getCumulativeViewMatrix(), object.getCumulativeModelMatrix(), mvMatrix)
            shaderProgram.setUniformMatrix4fv("mvMatrix", mvMatrix)
            shaderProgram.setUniformMatrix4fv("pMatrix", camera.getProjectionMatrix())
            normalMatrix = mat3.create()
            mat4.toInverseMat3(mvMatrix, normalMatrix)
            mat3.transpose(normalMatrix)
            shaderProgram.setUniformMatrix3fv("nMatrix", normalMatrix)
            object.getGraphicalModel().draw(shaderProgram, object.getTexture())
        )
