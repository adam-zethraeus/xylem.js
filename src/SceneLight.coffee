class SceneLight extends SceneNode

    constructor: (type)->
        super()
        if type?
            @type = type
        else
            @type = "point"
        @ambientColour = null
        @diffuseColour = null
        @specularColour = null
        @specularHardness = null

    setAmbientColour: (@ambientColour)->

    getAmbientColour: ()->
        return @ambientColour

    setDiffuseColour: (@diffuseColour)->

    getDiffuseColour: ()->
        return @diffuseColour

    setSpecularColour: (@specularColour)->

    getSpecularColour: ()->
        return @specularColour

    setSpecularHardness: (@specularHardness)->

    getSpecularHardness: ()->
        return @specularHardness
