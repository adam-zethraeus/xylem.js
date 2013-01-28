class Texture

	constructor: (@glContext, image)->
		if not image.src
			throw "Texture image was not loaded."
		@glTexture = @glContext.createTexture()
		@glTexture.image = image
		@glContext.pixelStorei(@glContext.UNPACK_FLIP_Y_WEBGL, true)
		@glContext.bindTexture(@glContext.TEXTURE_2D, @glTexture)
		@glContext.texImage2D(@glContext.TEXTURE_2D, 0, @glContext.RGBA, @glContext.RGBA, @glContext.UNSIGNED_BYTE, @glTexture.image)
		@glContext.texParameteri(@glContext.TEXTURE_2D, @glContext.TEXTURE_MAG_FILTER, @glContext.LINEAR)
		@glContext.texParameteri(@glContext.TEXTURE_2D, @glContext.TEXTURE_MIN_FILTER, @glContext.LINEAR_MIPMAP_NEAREST)
		@glContext.generateMipmap(@glContext.TEXTURE_2D)
		@glContext.bindTexture(@glContext.TEXTURE_2D, null)

	getGLTexture: ()->
		return @glTexture

	bind: (glTextureID)->
		@glContext.activeTexture(glTextureID)
		@glContext.bindTexture(@glContext.TEXTURE_2D, @glTexture)

	unbind: ()->
		#No Op.