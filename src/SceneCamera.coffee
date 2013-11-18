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

    updateStateFromActiveKeys: (activeKeys)->
        translation = [0,0,0]
        translation[2] = -0.1 if !!activeKeys[87]
        translation[2] = 0.1 if !!activeKeys[83]
        translation[0] = -0.1 if !!activeKeys[65]
        translation[0] = 0.1 if !!activeKeys[68]
        @translate(translation)

        #pitch
        axis = [1,0,0]
        radians = 0
        radians = 0.03 if !!activeKeys[73]
        radians = -0.03 if !!activeKeys[75]
        @rotate(radians, axis) if radians != 0
        #yaw
        axis = [0,1,0]
        radians = 0
        radians = 0.03 if !!activeKeys[74]
        radians = -0.03 if !!activeKeys[76]
        @rotate(radians, axis) if radians != 0
        #roll
        axis = [0,0,1]
        radians = 0
        radians = 0.03 if !!activeKeys[85]
        radians = -0.03 if !!activeKeys[79]
        @rotate(radians, axis) if radians != 0
