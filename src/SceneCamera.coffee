class SceneCamera extends SceneNode

    constructor: ()->
        super()
        @viewMatrix = mat4.create()
        @projectionMatrix = mat4.create()
        @cumulativeViewMatrix = mat4.create()
        @inverseProjectionMatrix = mat4.create()

    setProperties: (fov, viewportWidth, viewportHeight, @nearClip, @farClip)->
        mat4.perspective(@projectionMatrix, fov, viewportWidth / viewportHeight, nearClip, farClip)
        mat4.invert(@inverseProjectionMatrix, @projectionMatrix)

    getProjectionMatrix: ()->
        return @projectionMatrix

    getInverseProjectionMatrix: ()->
        return @inverseProjectionMatrix

    getViewMatrix: ()->
        @recalculateViewMatrix()
        return @viewMatrix

    recalculateViewMatrix: ()->
        mat4.invert(@viewMatrix, @modelMatrix)

    getCumulativeViewMatrix: ()->
        mat4.invert(@cumulativeViewMatrix, @cumulativeModelMatrix)
        return @cumulativeViewMatrix
