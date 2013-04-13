class Texture

    constructor: (@gl, @width, @height)->
        @id = @gl.createTexture()
        @gl.bindTexture(@gl.TEXTURE_2D, @id)
        @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR);
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR);
        # @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST)
        @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @width, @height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, null)
        # @gl.generateMipmap(@gl.TEXTURE_2D)
        @gl.bindTexture(@gl.TEXTURE_2D, null)
        @framebuffer = null
        @renderbuffer = null

    bind: (number)->
        @gl.activeTexture(@gl.TEXTURE0 + (number || 0))
        @gl.bindTexture(@gl.TEXTURE_2D, @id)

    unbind: (number)->
        @gl.activeTexture(@gl.TEXTURE0 + (number || 0))
        @gl.bindTexture(@gl.TEXTURE_2D, null)

    drawTo: (drawCallback, useDepth)->
        if not useDepth?
            useDepth = true
        hold = @gl.getParameter(@gl.VIEWPORT)
        @framebuffer = @framebuffer || @gl.createFramebuffer()
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, @framebuffer)
        @gl.framebufferTexture2D(@gl.FRAMEBUFFER, @gl.COLOR_ATTACHMENT0, @gl.TEXTURE_2D, @id, 0)
        if useDepth
            @renderbuffer = @renderbuffer || @gl.createRenderbuffer()
            @gl.bindRenderbuffer(@gl.RENDERBUFFER, @renderbuffer)
            @gl.renderbufferStorage(@gl.RENDERBUFFER, @gl.DEPTH_COMPONENT16, @width, @height)
            @gl.framebufferRenderbuffer(@gl.FRAMEBUFFER, @gl.DEPTH_ATTACHMENT, @gl.RENDERBUFFER, @renderbuffer)
        @gl.viewport(0, 0, @width, @height)

        drawCallback()

        @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, null)
        @gl.viewport(hold[0], hold[1], hold[2], hold[3])

    swapContents: (texture)->
        hold = texture.id
        texture.id = @id
        @id = hold
        hold = texture.width
        texture.width = @width
        @width = hold
        hold = texture.height
        texture.height = @height
        @height = hold

Texture.fromImage = (gl, image)->
    texture = new Texture(gl, image.width, image.height)
    gl.bindTexture(gl.TEXTURE_2D, texture.id)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image)
    # gl.generateMipmap(gl.TEXTURE_2D)
    gl.bindTexture(gl.TEXTURE_2D, null)
    return texture
