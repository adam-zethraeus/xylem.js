class SceneGraph
    constructor: ()->
        @rootNode = null

    setRoot: (@rootNode)->

    DFT: (act, initialData)->
        traverse = (node, data)->
            newData = act(node, data)
            for child in node.children
                traverse(child, newData)
        traverse(@rootNode, initialData) if @rootNode?

    # Example DFT act.
    #
    # The act logs all paths from root to leaf.
    # In this example the SceneNodes have an extra 'name' property.
    # NB: The act manipulates the passed data of its parent node 
    # and returns the new data to be passed to its children.
    #
    # act = (node, data)->
    #   list = data.concat(node.name)
    #   console.log(list) if node.children.length is 0
    #   return list
    # x.DFT(act, [])

    draw: (shaderProgram, camera)->
        startingModelMatrix = mat4.create()
        mat4.identity(startingModelMatrix)
        this.DFT(
            (node, parentModelMatrix)->
                # Accumulate model matrix with that of parent.
                cumulativeModelMatrix = mat4.create()
                mat4.multiply(node.getModelMatrix(), parentModelMatrix, cumulativeModelMatrix)
                # Use camera view to create ModelView Matrix, set in shader.
                mvMatrix = mat4.create()
                mat4.multiply(camera.getViewMatrix(), cumulativeModelMatrix, mvMatrix)
                if node.getGraphicalModel()?
                    shaderProgram.setUniformMatrix4fv("mvMatrix", mvMatrix)

                    # Set Projection Matrix.
                    shaderProgram.setUniformMatrix4fv("pMatrix", camera.getProjectionMatrix())

                    # Get Normal Matrix from ModelView. Set in shader.
                    normalMatrix = mat3.create()
                    mat4.toInverseMat3(mvMatrix, normalMatrix)
                    mat3.transpose(normalMatrix)
                    shaderProgram.setUniformMatrix3fv("nMatrix", normalMatrix)

                    # Draw the mesh with the set up Shader Program.
                    node.getGraphicalModel().draw(shaderProgram)

                # Return accumulated Model Matrix for use by child nodes.
                return cumulativeModelMatrix

            startingModelMatrix
        )