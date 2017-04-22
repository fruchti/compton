uniform float opacity;
uniform uvec2 position;
uniform uvec2 size;
uniform vec2 scale;
uniform bool invert_color;
uniform sampler2D tex;

void main()
{
    float nopacity;
	vec4 c = texture2D(tex, gl_TexCoord[0].st);
	if (invert_color)
		c = vec4(vec3(c.a, c.a, c.a) - vec3(c), c.a);

    float x = gl_TexCoord[0].s;
    float y = gl_TexCoord[0].t;
    const float rectThresh = 0.5;
    const float squareThresh = 0.8;

    float rectXLineWidth = 1.0 * scale.x;
    float rectYLineWidth = 1.0 * scale.y;
    const int nRects = 5;
    float rectXSpace = 9.0 * scale.x;
    float rectYSpace = 9.0 * scale.y;
    const vec4 rectColor = vec4(0.0, 0.4, 1.0, 1.0);

    if(opacity < rectThresh)
    {
        bool rectFound = false;
        for(int i = 0; i < nRects; i++)
        {
            float top = 0.5 - (opacity / rectThresh) * 0.5 + rectYSpace * float(i);
            float bot = 0.5 + (opacity / rectThresh) * 0.5 - rectYSpace * float(i);
            float left = 0.5 - (opacity / rectThresh) * 0.5 + rectXSpace * float(i);
            float right = 0.5 + (opacity / rectThresh) * 0.5 - rectXSpace * float(i);

            if((x > left - rectXLineWidth) && (x < right + rectXLineWidth) &&
                    (y > top - rectYLineWidth) && (y < bot + rectYLineWidth) &&
                    ((x < left + rectXLineWidth) || (x > right - rectXLineWidth) ||
                     (y < top + rectYLineWidth) || (y > bot - rectYLineWidth)))
            {
                c = rectColor;
                nopacity = opacity / rectThresh;
                nopacity *= (float(nRects) - float(i)) / float(nRects);
                rectFound = true;
                break;
            }
        }
        if(!rectFound)
        {
            nopacity = 0.0;
        }
    }
    else if(opacity < squareThresh)
    {
        const float blockXSize = 420.0;
        const float blockYSize = 170.0;
        float block = floor((x / scale.x + position.x) / blockXSize) + 0.47 * floor((y / scale.y + position.y) / blockYSize);
        if(mod(block / ((opacity - rectThresh) / (squareThresh - rectThresh)), 1.5) < 0.1)
        {
            nopacity = opacity * 0.5;
        }
        else
        {
            nopacity = opacity;
        }
    }
    else
    {
        nopacity = opacity;
    }

	c *= nopacity;
	gl_FragColor = c;
}
