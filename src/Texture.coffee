class Texture

    constructor: (@gl, image)->
        if not image.src?
            throw "Texture image was not loaded."
        @glTexture = @gl.createTexture()
        @glTexture.image = image
        @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)
        @gl.bindTexture(@gl.TEXTURE_2D, @glTexture)
        @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, @glTexture.image)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST)
        @gl.generateMipmap(@gl.TEXTURE_2D)
        @gl.bindTexture(@gl.TEXTURE_2D, null)

    getGLTexture: ()->
        return @glTexture

    bind: (glTextureID)->
        @gl.activeTexture(@gl.TEXTURE0 + glTextureID)
        @gl.bindTexture(@gl.TEXTURE_2D, @glTexture)

    unbind: ()->
        #No Op.