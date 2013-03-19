class Texture

    constructor: (@gl, @width, @height)->
        @id = @gl.createTexture()
        @gl.bindTexture(@gl.TEXTURE_2D, @id)
        @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST)
        @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @width, @height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, null)
        @gl.bindTexture(@gl.TEXTURE_2D, null)

    bind: (number)->
        @gl.activeTexture(@gl.TEXTURE0 + (number || 0))
        @gl.bindTexture(@gl.TEXTURE_2D, @id)

    unbind: (number)->
        @gl.activeTexture(@gl.TEXTURE0 + (number || 0))
        @gl.bindTexture(@gl.TEXTURE_2D, null)

    drawTo: (drawCallback)->
        hold = @gl.getParameter(@gl.VIEWPORT)
        framebuffer = @gl.createFramebuffer()
        renderbuffer = @gl.createRenderbuffer()
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, framebuffer)
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, renderbuffer)
        renderbuffer.width = @width
        renderbuffer.height = @height
        @gl.renderbufferStorage(@gl.RENDERBUFFER, @gl.DEPTH_COMPONENT16, @width, @height)
        @gl.framebufferTexture2D(@gl.FRAMEBUFFER, @gl.COLOR_ATTACHMENT0, @gl.TEXTURE_2D, @id, 0)
        @gl.framebufferRenderbuffer(@gl.FRAMEBUFFER, @gl.DEPTH_ATTACHMENT, @gl.RENDERBUFFER, renderbuffer)
        @gl.viewport(0, 0, @width, @height)

        drawCallback()

        @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, null)
        @gl.viewport(hold[0], hold[1], hold[2], hold[3])

Texture.fromImage = (gl, image)->
    texture = new Texture(gl, image.width, image.height)
    gl.bindTexture(gl.TEXTURE_2D, texture.id)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image)
    gl.generateMipmap(gl.TEXTURE_2D)
    return texture
