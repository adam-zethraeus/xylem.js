class Texture

	constructor: (@glContext)->
		@texture = @glContext.createTexture()
		@texture.image = new Image()
	
	setImage: (url, callback)->
		@texture.image.onload = ()=>
			@glContext.pixelStorei(@glContext.UNPACK_FLIP_Y_WEBGL, true)
			@glContext.bindTexture(@glContext.TEXTURE_2D, @texture)
			@glContext.texImage2D(@glContext.TEXTURE_2D, 0, @glContext.RGBA, @glContext.RGBA, @glContext.UNSIGNED_BYTE, @texture.image)
			@glContext.texParameteri(@glContext.TEXTURE_2D, @glContext.TEXTURE_MAG_FILTER, @glContext.LINEAR)
			@glContext.texParameteri(@glContext.TEXTURE_2D, @glContext.TEXTURE_MIN_FILTER, @glContext.LINEAR_MIPMAP_NEAREST)
			@glContext.generateMipmap(@glContext.TEXTURE_2D)
			@glContext.bindTexture(@glContext.TEXTURE_2D, null)
			callback()
		@texture.image.src = url

	getTexture: ()->
		return @texture