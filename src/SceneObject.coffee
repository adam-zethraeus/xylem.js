class SceneObject extends SceneNode

    constructor: ()->
        super()
        @graphicalModel = null
        @texture = null

    scale: (proportion)->
        mat4.scale(@modelMatrix, proportion)

    setModel: (@graphicalModel)->

    getGraphicalModel: ()->
        return @graphicalModel

    setTexture: (@texture)->
        return null

    getTexture: ()->
        return @texture