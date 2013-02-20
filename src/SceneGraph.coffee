class SceneGraph
    constructor: ()->
        @rootNode = null

    setRoot: (@rootNode)->

    getRoot: ()->
        return @rootNode

    #TODO: actually accumulate MVM
    getNodesOfType: (type)->
        list = []
        startingModelMatrix = mat4.create()
        mat4.identity(startingModelMatrix)
        preOrder = (node, parentModelMatrix, type) ->
            # Accumulate model matrix with that of parent.
            cumulativeModelMatrix = mat4.create()
            mat4.multiply(parentModelMatrix, node.getModelMatrix(), cumulativeModelMatrix)
            node.cumulativeModelMatrix = cumulativeModelMatrix
            # Use camera view to create ModelView Matrix, set in shader.
            if node instanceof type
                list.push(node)
            for child in node.children
                # continue with accumulated Model Matrix for use by child nodes.
                preOrder(child, cumulativeModelMatrix, type)
        preOrder(@rootNode, startingModelMatrix, type)
        return list

    draw: (shaderProgram)->
        startingModelMatrix = mat4.create()
        mat4.identity(startingModelMatrix)
        camera = this.getNodesOfType(SceneCamera)[0]
        light = this.getNodesOfType(SceneLight)[0]
        light.setUniforms(shaderProgram, [0,0,0])
        preOrder = (node, parentModelMatrix) ->
            # Accumulate model matrix with that of parent.
            cumulativeModelMatrix = mat4.create()
            mat4.multiply(parentModelMatrix, node.getModelMatrix(), cumulativeModelMatrix)
            # Use camera view to create ModelView Matrix, set in shader.
            mvMatrix = mat4.create()
            mat4.multiply(camera.getCumulativeViewMatrix(), cumulativeModelMatrix, mvMatrix)
            if node instanceof SceneObject
                shaderProgram.setUniformMatrix4fv("mvMatrix", mvMatrix)

                # Set Projection Matrix.
                shaderProgram.setUniformMatrix4fv("pMatrix", camera.getProjectionMatrix())

                # Get Normal Matrix from ModelView. Set in shader.
                normalMatrix = mat3.create()
                mat4.toInverseMat3(mvMatrix, normalMatrix)
                mat3.transpose(normalMatrix)
                shaderProgram.setUniformMatrix3fv("nMatrix", normalMatrix)

                # Draw the mesh with the set up Shader Program.
                node.getGraphicalModel().draw(shaderProgram, node.getTexture())

            for child in node.children
                # continue with accumulated Model Matrix for use by child nodes.
                preOrder(child, cumulativeModelMatrix)
        preOrder(@rootNode, startingModelMatrix)