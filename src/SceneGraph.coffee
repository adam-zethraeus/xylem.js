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
        preOrder = (node, type, act)->
            if node instanceof type
                act(node)
            for child in node.children
                preOrder(child, type, act)
        preOrder(@rootNode, type, act)

    draw: (shaderProgram, camera)->
        startingModelMatrix = mat4.create()
        mat4.identity(startingModelMatrix)
        @rootNode.accumulateModelMatrix(startingModelMatrix)
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
