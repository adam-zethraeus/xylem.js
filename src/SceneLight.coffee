class SceneLight extends SceneNode

    constructor: (type)->
        super()
        if type?
            @type = type
        else
            @type = "point"
        @diffuseColor = null
        @specularColor = null
        @specularHardness = null
        @constantAttenuation = null
        @linearAttenuation = null
        @quadraticAttenuation = null

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

    setConstantAttenuation: (@constantAttenuation)->

    getConstantAttenuation: ()->
        return @constantAttenuation

    setLinearAttenuation: (@linearAttenuation)->

    getLinearAttenuation: ()->
        return @linearAttenuation

    setQuadraticAttenuation: (@quadraticAttenuation)->

    getQuadraticAttenuation: ()->
        return @quadraticAttenuation

    setUniforms: (shaderProgram, translation)->
        shaderProgram.setUniform3f("pointLightDiffuseColor", @diffuseColor)
        shaderProgram.setUniform3f("pointLightSpecularColor", @specularColor)
        shaderProgram.setUniform3f("pointLightLocation", translation)
        shaderProgram.setUniform1f("specularHardness", @specularHardness)
        shaderProgram.setUniform1f("constantAttenuation", @constantAttenuation)
        shaderProgram.setUniform1f("linearAttenuation", @linearAttenuation)
        shaderProgram.setUniform1f("quadraticAttenuation", @quadraticAttenuation)
