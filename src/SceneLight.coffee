class SceneLight extends SceneNode

    constructor: (type)->
        super()
        if type?
            @type = type
        else
            @type = "point"
        @ambientColor = null
        @diffuseColor = null
        @specularColor = null
        @specularHardness = null

    setAmbientColor: (@ambientColor)->

    getAmbientColor: ()->
        return @ambientColor

    setDiffuseColor: (@diffuseColor)->

    getDiffuseColor: ()->
        return @diffuseColor

    setSpecularColor: (@specularColor)->

    getSpecularColor: ()->
        return @specularColor

    setSpecularHardness: (@specularHardness)->

    getSpecularHardness: ()->
        return @specularHardness

    setUniforms: (shaderProgram, translation)->
        shaderProgram.setUniform3f("pointLightingDiffuseColor", @diffuseColor)
        shaderProgram.setUniform3f("pointLightingSpecularColor", @specularColor)
        shaderProgram.setUniform3f("ambientColor", @ambientColor)
        shaderProgram.setUniform3f("pointLightingLocation", translation)
        shaderProgram.setUniform1f("specularHardness", @specularHardness)