class SceneNode

    constructor: ()->
        @modelMatrix = mat4.create()
        @cumulativeModelMatrix = mat4.create()
        @children = []
        @parentNode = null
        @resetModelMatrix()

    translate: (vector)->
        mat4.translate(@modelMatrix, @modelMatrix, vector)
    
    rotate: (degrees, axis)->
        mat4.rotate(@modelMatrix, @modelMatrix, degrees, axis)

    resetModelMatrix: ()->
        mat4.identity(@modelMatrix)
        mat4.identity(@cumulativeModelMatrix)

    getModelMatrix: ()->
        return @modelMatrix

    getCumulativeModelMatrix: ()->
        return @cumulativeModelMatrix

    accumulateModelMatrix: (parentAccumulatedModelMatrix)->
        mat4.multiply(@cumulativeModelMatrix, parentAccumulatedModelMatrix, @modelMatrix)
        for node in @children
            node.accumulateModelMatrix(@cumulativeModelMatrix)

    addChild: (node)->
        node.setParent(@)
        @children.push(node)

    reparentTo: (node)->
        if @parentNode
            @parentNode.removeChild(@)
        node.addChild(@)

    setParent: (@parentNode)->

    removeChild: (node)->
        index = @children.indexOf(node)
        return if index is -1
        @children = @children.slice(0, index) + @children.slice(index + 1)

    getChildren: ()->
        return @children
