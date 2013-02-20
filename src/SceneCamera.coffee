class SceneCamera extends SceneNode

    constructor: ()->
        super()
        @viewMatrix = mat4.create()
        @projectionMatrix = mat4.create()
        @cumulativeModelMatrix = null
        @cumulativeViewMatrix = mat4.create()

    setProperties: (fov, viewportWidth, viewportHeight, nearClip, farClip)->
        mat4.perspective(fov, viewportWidth / viewportHeight, nearClip, farClip, @projectionMatrix)

    getProjectionMatrix: ()->
        return @projectionMatrix

    getViewMatrix: ()->
        this.recalculateViewMatrix()
        return @viewMatrix

    recalculateViewMatrix: ()->
        mat4.inverse(@modelMatrix, @viewMatrix)

    getCumulativeViewMatrix: ()->
        # This class doesn't track @cumulative
        mat4.inverse(@cumulativeModelMatrix, @cumulativeViewMatrix)
        return @cumulativeViewMatrix