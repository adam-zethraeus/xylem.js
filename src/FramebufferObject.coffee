class FramebufferObject

    constructor: (@gl, @width, @height)->
        if not @width? or not @height?
            @width = @gl.viewportWidth
            @height = @gl.viewportHeight
        @framebuffer = @gl.createFramebuffer()
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, @framebuffer)
        @texture = @gl.createTexture();
        @gl.bindTexture(@gl.TEXTURE_2D, @texture);
        @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @width, @height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, null);
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR);
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST);
        @gl.generateMipmap(@gl.TEXTURE_2D);
        @renderbuffer = @gl.createRenderbuffer()
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, @renderbuffer)
        @gl.renderbufferStorage(@gl.RENDERBUFFER, @gl.DEPTH_COMPONENT16, @width, @height);
        @gl.framebufferTexture2D(@gl.FRAMEBUFFER, @gl.COLOR_ATTACHMENT0, @gl.TEXTURE_2D, @texture, 0);
        @gl.framebufferRenderbuffer(@gl.FRAMEBUFFER, @gl.DEPTH_ATTACHMENT, @gl.RENDERBUFFER, @renderbuffer);
        
        @gl.bindTexture(@gl.TEXTURE_2D, null);
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, null);
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, null);