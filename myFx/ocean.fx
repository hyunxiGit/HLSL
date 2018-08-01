float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 wvpi : WORLDVIEWPROJI;

float4x4 world : WORLD;
float3 max_dis = { 10, 10, 100 };
float time : TIME;
int index = 0;

float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = { -0.577, -0.577, 0.577 };

texture tex0
<
    string name = "ocean.tga"; 
    string UIName = "diffuse";
>;

sampler2D diffuseSampler = sampler_state
{
    Texture = <tex0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};

struct VSin
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
};

struct VSout
{
    float4 pos : POSITION;
    float4 pos2 : COLOR0;
    float2 UV : TEXCOORD0;
    float2 UV2 : TEXCOORD1;
    float4 NORMAL : TEXCOORD2;
};

float2 transUV(float2 uv, float2 tile, float2 offset)
{
    float2 outUV = uv * tile + offset;
    return outUV;
}

void transPos(inout float4 pos, float scale)
{
    float z = (cos(pos.x / 70) + cos(pos.y / 70)) / 2 * scale;
    pos.z = z;
}

float4 transNormal(float4 p, float scaler)
{
    float4 N;

    //this factor doesn't reanlly matter
    float posOffset = 1.0f;
    float4 p1 = float4(p.x + posOffset, p.y, p.z, 1.0f);
    float4 p2 = float4(p.x - posOffset, p.y, p.z, 1.0f);
    float4 p3 = float4(p.x, p.y + posOffset, p.z, 1.0f);
    float4 p4 = float4(p.x, p.y - posOffset, p.z, 1.0f);

    transPos(p1, max_dis.z);
    transPos(p2, max_dis.z);
    transPos(p3, max_dis.z);
    transPos(p4, max_dis.z);

    float4 du = p1 - p2;
    float4 dv = p3 - p4;
    N = float4(normalize(cross(du.xyz, dv.xyz)), 1);

    return N;
}

VSout VS(VSin IN)
{
    VSout OUT = (VSout) 0;

    float4 p = IN.pos;

    //OUT.NORMAL = transNormal(p, max_dis.z);
    //transPos(p, max_dis.z);

    OUT.UV = IN.UV;
    //OUT.UV2 = transUV(IN.UV, float2(2, 1), float2(time / 10000, 0));
    OUT.pos = mul(p, wvp);
    OUT.pos2 = p;
    return OUT;
}

float4 colorToGrey(float4 myCol)
{
    float4 col;
    float grey = myCol.r * 0.3f + myCol.g * 0.59 + myCol.b * 0.11f;
    col.rgb = grey;
    col.a = myCol.a;
    return col;
}

float4 HeighMapToNormal(sampler2D tSampler, float2 UV)
{
    float4 col;
    float uPixel = (float) 1.0 / 128;
    float vPixel = (float) 1.0 / 128;

    float4 height_pu = tex2D(tSampler, UV + float2(uPixel, 0));
    float4 height_mu = tex2D(tSampler, UV - float2(uPixel, 0));
    float4 height_pv = tex2D(tSampler, UV + float2(0, vPixel));
    float4 height_mv = tex2D(tSampler, UV - float2(0, vPixel));

    float du = colorToGrey(height_mu - height_pu).r;
    float dv = colorToGrey(height_mv - height_pv).r;
    float3 N = normalize(float3(du, dv, 1.0 / 2));

    col = float4(N, 1);
    return col;
}

float4 PS(VSout IN) : COLOR
{
    float4 col;

    float4 N = float4(normalize(mul(IN.NORMAL.xyz, (float3x3) world)), 1);
    float3 L = lightDir;
    
    float4 diffuse = tex2D(diffuseSampler, IN.UV2);
    
    //lighting
    col = max(dot(N.xyz, L), 0);
    col.a = 1;

    /*show normal*/
    //col = IN.NORMAL;
    

    return col;
}

const float2 gradientV[4] =
{
    float2(1, 1),
    float2(-1, 1),
    float2(1, -1),
    float2(-1, -1)
};

const int permutation[256] =
{
    151, 160, 137, 91, 90, 15,
   131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
   190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
   88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
   77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
   102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
   135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
   5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
   223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
   129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
   251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
   49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
   138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
};

const int4 permutation_test[64] =
{
    151, 160, 137, 91, 90, 15,
   131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
   190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
   88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
   77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
   102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
   135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
   5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
   223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
   129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
   251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
   49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
   138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
};

int pg(int i)
{
    i = i % 256;

    int y = floor(i / 4);
    int x = i % 4;

    int4 t = permutation_test[y];
    return t[x];
}

int psudurandom(float x, float y, float z)
{
    int r = pg(pg(pg(x) + y) + z);
    return r;
}


float fade(float t)
{
    return t * t * t * (t * (t * 6 - 15) + 10);
}

int inc(int i)
{
    return i + 1;
}

float grad (int hash, float x , float y , float z)
{
    float value;
    int h = hash % 16;

    float u = h < 8 /* 0b1000 */ ? x : y; // If the most significant bit (MSB) of the hash is 0 then set u = x.  Otherwise y.
    
    float v; // In Ken Perlin's original implementation this was another conditional operator (?:).  I
                                                          // expanded it for readability.  
    if (h < 4 /* 0b0100 */)                                // If the first and second significant bits are 0 set v = y
        v = y;
    else if (h == 12 /* 0b1100 */ || h == 14 /* 0b1110*/)  // If the first and second significant bits are 1 set v = x
        v = x;
    else // If the first and second significant bits are not equal (0/1, 1/0) set v = z
        v = z;
    
    int r1 = (h % 2) * (-2)+1;
    int r2 = (h % 4) < 2 ? 1 : -1;

    value = r1 * u + r2 * v;

    //value = ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    return value;
}

float fadeLerp(float a, float b, float f)
{
    return lerp(a, b, f);
}

float4 perlin(float4 p)
{
    //grid
    float x = p[0];
    float y = p[1];
    float z = p[2];
    
    int xi = floor(x) % 255;
    int yi = floor(y) % 255;
    int zi = floor(z) % 255;

    //fraction
    float xf = frac(x);
    float yf = frac(y);
    float zf = frac(z);

    //psuduRandom
    int aaa, aba, aab, abb, baa, bba, bab, bbb;
    aaa = psudurandom(xi, yi, zi);
    aba = psudurandom(xi, inc(yi), zi);
    aab = psudurandom(xi, yi, inc(zi));
    abb = psudurandom(xi, inc(yi), inc(zi));
    baa = psudurandom(inc(xi), yi, zi);
    bba = psudurandom(inc(xi), inc(yi), zi);
    bab = psudurandom(inc(xi), yi, inc(zi));
    bbb = psudurandom(inc(xi), inc(yi), inc(zi));

    //grad
    float x1 = lerp(grad(aaa, xf, yf, zf),      grad(baa, xf - 1, yf, zf),      xf);
    float x2 = lerp(grad(aba, xf, yf - 1, zf),  grad(bba, xf - 1, yf - 1, zf),  xf);
    float y1 = lerp(x1, x2, yf);
  
    x1 = lerp(grad(aab, xf, yf, zf - 1),        grad(bab, xf - 1, yf, zf - 1),      xf);
    x2 = lerp(grad(abb, xf, yf - 1, zf - 1),    grad(bbb, xf - 1, yf - 1, zf - 1),  xf);

    float y2 = lerp(x1, x2, yf);
    
    float z1 = (lerp(y1, y2, zf) + 1) / 2; //change range to (0,1)

    float4 col = 0.4f;
    return col;
}

float4 perlin_test(float4 p)
{
    p += 1000; //fake to be all positive
    //grid
    float x = p[0];
    float y = p[1];
    float z = p[2];
    
    //256 size grid
    int xi = floor(x) % 256;
    int yi = floor(y) % 256;
    int zi = floor(z) % 256;

    //fraction
    float xf = frac(x);
    float yf = frac(y);
    float zf = frac(z);

    //psuduRandom
    int aaa, aba, aab, abb, baa, bba, bab, bbb;
    aaa = psudurandom(xi, yi, zi);
    aba = psudurandom(xi, inc(yi), zi);
    aab = psudurandom(xi, yi, inc(zi));
    abb = psudurandom(xi, inc(yi), inc(zi));
    baa = psudurandom(inc(xi), yi, zi);
    bba = psudurandom(inc(xi), inc(yi), zi);
    bab = psudurandom(inc(xi), yi, inc(zi));
    bbb = psudurandom(inc(xi), inc(yi), inc(zi));

    //grad
    float x1 = lerp(grad(aaa, xf, yf, zf), grad(baa, xf - 1, yf, zf), xf);
    float x2 = lerp(grad(aba, xf, yf - 1, zf), grad(bba, xf - 1, yf - 1, zf), xf);
    float y1 = lerp(x1, x2, yf);
  
    x1 = lerp(grad(aab, xf, yf, zf - 1), grad(bab, xf - 1, yf, zf - 1), xf);
    x2 = lerp(grad(abb, xf, yf - 1, zf - 1), grad(bbb, xf - 1, yf - 1, zf - 1), xf);

    float y2 = lerp(x1, x2, yf);
    
    float z1 = (lerp(y1, y2, zf) + 1) / 2; //change range to (0,1)

    float4 col = z1;
    return col;
}

float4 PS2(VSout IN) : COLOR
{
    float4 p = mul(IN.pos, wvpi);
    float4 col = perlin_test(IN.pos2);
    return col;
}

technique test2
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        //alphatestenable = true;
        //alphafunc = greaterequal;
        //alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS2();
    }
}

technique main
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        //alphatestenable = true;
        //alphafunc = greaterequal;
        //alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}

technique allAlpha
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        alphatestenable = true;
        alphafunc = greaterequal;
        alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
    
}
