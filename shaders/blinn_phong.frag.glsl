    precision mediump float;

    varying vec2 vTextureCoord;
    varying vec3 vTransformedNormal;
    varying vec3 vColor;
    varying vec4 vPosition;

    uniform float specularHardness;
    uniform float textureOpacity;
    uniform vec3 ambientColor;
    uniform vec3 pointLightingLocation;
    uniform vec3 pointLightingSpecularColor;
    uniform vec3 pointLightingDiffuseColor;

    uniform sampler2D sampler;


    void main(void) {
        vec3 lightWeighting;
            vec3 lightDirection = normalize(pointLightingLocation - vPosition.xyz);
            vec3 normal = normalize(vTransformedNormal);

            vec3 eyeDirection = normalize(-vPosition.xyz);
            vec3 reflectionDirection = reflect(-lightDirection, normal);

            float specularLightWeighting = pow(max(dot(reflectionDirection, eyeDirection), 0.0), specularHardness);

            float diffuseLightWeighting = max(dot(normal, lightDirection), 0.0);
            lightWeighting = ambientColor
                + pointLightingSpecularColor * specularLightWeighting
                + pointLightingDiffuseColor * diffuseLightWeighting;

        vec4 fragmentColor = vec4(vColor, 1.0) * (1.0 - textureOpacity) + texture2D(sampler, vec2(vTextureCoord.s, vTextureCoord.t)) * textureOpacity;
        gl_FragColor = vec4(fragmentColor.rgb * lightWeighting, fragmentColor.a);
    }