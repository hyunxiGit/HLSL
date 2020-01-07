Texture2D<float4> HDRTex		: register( t0 );
StructuredBuffer<float> AvgLum	: register( t1 );

SamplerState PointSampler		: register( s0 );

static const float2 arrBasePos[4] = {
	float2(-1.0, 1.0),
	float2(1.0, 1.0),
	float2(-1.0, -1.0),
	float2(1.0, -1.0),
};

static const float2 arrUV[4] = {
	float2(0.0, 0.0),
	float2(1.0, 0.0),
	float2(0.0, 1.0),
	float2(1.0, 1.0),
};

//-----------------------------------------------------------------------------------------
// Vertex shader
//-----------------------------------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Position : SV_Position; // vertex position 
	float2 UV		: TEXCOORD0;
};

VS_OUTPUT FullScreenQuadVS( uint VertexID : SV_VertexID )
{
    VS_OUTPUT Output;

    Output.Position = float4( arrBasePos[VertexID].xy, 0.0, 1.0);
    Output.UV = arrUV[VertexID].xy;
    
    return Output;    
}

//-----------------------------------------------------------------------------------------
// Pixel shader
//-----------------------------------------------------------------------------------------

cbuffer FinalPassConstants : register( b0 )
{
	// Tone mapping
	float MiddleGrey	: packoffset( c0 );
	float LumWhiteSqr	: packoffset( c0.y );
}

static const float3 LUM_FACTOR = float3(0.299, 0.587, 0.114);

float3 ToneMapping(float3 HDRColor)
{
	// Find the luminance scale for the current pixel
	float LScale = dot(HDRColor, LUM_FACTOR);
	LScale *= MiddleGrey / AvgLum[0];
	LScale = (LScale + LScale * LScale / LumWhiteSqr) / (1.0 + LScale);
	
	// Apply the luminance scale to the pixels color
	return HDRColor * LScale;
}

float4 FinalPassPS( VS_OUTPUT In ) : SV_TARGET
{
	// Get the color sample
	float3 color = HDRTex.Sample( PointSampler, In.UV.xy ).xyz;

    float cValue = (color.x + color.y + color.z) / 3;
	
	//radial coord
    float2 uv = normalize(In.UV * 2 - 1);
	//uv offset on god ray direction
    float2 rayUVOffset = ddx(In.UV) * uv.x + ddy(In.UV) * uv.y;
	
	//sample 32 times along the effect width
    float3 rayColor = float3(0, 0, 0);
    float wdith = 70;
    float2 uvOffset = float2(0, 0);
    for (int i = 0; i < 32;++i)
    {
        uvOffset = wdith * i / 32 * rayUVOffset;
        rayColor += HDRTex.Sample(PointSampler, In.UV.xy + uvOffset).xyz;
    }
    rayColor /= 32;
	
	//compose
    color += 0.3 * rayColor;
		// Tone mapping
	color = ToneMapping(color);
    return float4(color, 1);

}