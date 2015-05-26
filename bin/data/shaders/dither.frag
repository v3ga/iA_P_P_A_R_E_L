precision highp float;

uniform sampler2D src_tex_unit0;
uniform float useTexture;
uniform float useColors;
uniform vec4 globalColor;


varying float depth;
varying vec4 colorVarying;
varying vec2 texCoordVarying;

//--------------------------------------------------------------
float find_closest(int x, int  y, float c0)
{
    mat4 dither = mat4(
        1.0,  33.0,  9.0, 41.0,
        49.0, 17.0, 57.0, 25.0,
        13.0, 45.0,  5.0, 37.0,
        61.0, 29.0, 53.0, 21.0 );
    
    float limit = 0.0;
    if(x < 4) {
        if(y >= 4) {
            limit = (dither[x][y-4]+3.0)/65.0;
        } else {
            limit = (dither[x][y])/65.0;
        }
    }
        
    if(x >= 4) {
        if(y >= 4)
            limit = (dither[x-4][y-4]+1.0)/65.0;
        else
            limit = (dither[x-4][y]+2.0)/65.0;
    }
        
    if(c0 < limit)
        return 0.0;
    
    return 1.0;
}

//--------------------------------------------------------------
void main() 
{
    float grayscale = dot( texture2D(src_tex_unit0,vec2(texCoordVarying.x,texCoordVarying.y)), vec4(0.299, 0.587, 0.114, 0));
    vec2 xy = gl_FragCoord.xy;
    
    int x = int(mod(xy.x, 8.0));
    int y = int(mod(xy.y, 8.0));
    float final = find_closest(x, y, grayscale);
    if (final == 1.0)
        gl_FragColor = vec4(final, final, final, 1.0);
    else
        gl_FragColor = vec4(0.0,0.0,0.0, 0.0);



//    gl_FragColor = texture2D(src_tex_unit0,vec2(texCoordVarying.x,texCoordVarying.y));
}

