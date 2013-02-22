class SceneNode

    constructor: ()->
        @modelMatrix = mat4.create()
        @cumulativeModelMatrix = mat4.create()
        @children = []
        @parentNode = null
        this.resetModelMatrix()

    translate: (vector)->
        mat4.translate(@modelMatrix, vector)
    
    rotate: (degrees, axis)->
        mat4.rotate(@modelMatrix, degrees, axis)

    resetModelMatrix: ()->
        mat4.identity(@modelMatrix)
        mat4.identity(@cumulativeModelMatrix)

    getModelMatrix: ()->
        return @modelMatrix

    getCumulativeModelMatrix: ()->
        return @cumulativeModelMatrix

    accumulateModelMatrix: (parentAccumulatedModelMatrix)->
        mat4.multiply(parentAccumulatedModelMatrix, @modelMatrix, @cumulativeModelMatrix)
        for node in @children
            node.accumulateModelMatrix(@cumulativeModelMatrix)

    addChild: (node)->
        node.setParent(this)
        @children.push(node)

    reparentTo: (node)->
        if @parentNode
            @parentNode.removeChild(this)
        node.addChild(this)

    setParent: (@parentNode)->

    removeChild: (node)->
        index = @children.indexOf(node)
        return if index is -1
        @children = @children.slice(0, index) + @children.slice(index + 1)

    getChildren: ()->
        return @children