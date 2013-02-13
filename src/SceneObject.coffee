class SceneObject extends SceneNode

    constructor: ()->
        super()
        @graphicalModel = null

    scale: (proportion)->
        mat4.scale(@modelMatrix, proportion)

    setModel: (@graphicalModel)->

    getGraphicalModel: ()->
        return @graphicalModel