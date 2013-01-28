    attribute vec3 vertexPosition;
    attribute vec3 vertexNormal;
    attribute vec2 textureCoord;

    uniform mat4 mvMatrix;
    uniform mat4 pMatrix;
    uniform mat3 nMatrix;

    varying vec2 vTextureCoord;
    varying vec3 vTransformedNormal;
    varying vec4 vPosition;


    void main(void) {
        vPosition = mvMatrix * vec4(vertexPosition, 1.0);
        gl_Position = pMatrix * vPosition;
        vTextureCoord = textureCoord;
        vTransformedNormal = nMatrix * vertexNormal;
    }