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

    setUniforms: (shaderProgram, translation)->
        shaderProgram.setUniform3f("pointLightingDiffuseColor", @diffuseColour)
        shaderProgram.setUniform3f("pointLightingSpecularColor", @specularColour)
        shaderProgram.setUniform3f("ambientColor", @ambientColour)
        shaderProgram.setUniform3f("pointLightingLocation", translation)
        shaderProgram.setUniform1f("specularHardness", @specularHardness)