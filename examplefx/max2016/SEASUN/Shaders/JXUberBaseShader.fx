#ifndef COMMON
	#include "../Common/Common.hlsli"
#endif 

#include "../Common/UberBaseParams.hlsli"


// Map usuge
DECLARE_MATERIAL_VARIABLE("Use Diffuse Map", _use_diffuse_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Metal Map", _use_metal_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Gloss Map", _use_gloss_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Normal Map", _use_normal_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Detail Map", _use_detail_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Emissive Map", _use_emissive_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Backscatter Map", _use_backscatter_map, bool, true)
DECLARE_MATERIAL_VARIABLE("Use Environment Map", _use_environment_map, bool, true)

// Map matrix
DECLARE_MATERIAL_VARIABLE("Advanced Map Mat X", _adv_mat_x, float4, DEF_MAT_X)
DECLARE_MATERIAL_VARIABLE("Advanced Map Mat Y", _adv_mat_y, float4, DEF_MAT_Y)
DECLARE_MATERIAL_VARIABLE("Advanced Map Mat Z", _adv_mat_z, float4, DEF_MAT_Z)
DECLARE_MATERIAL_VARIABLE("Advanced Map Mat W", _adv_mat_w, float4, DEF_MAT_W)

// Samplers
DECLARE_SAMPLER_2D("Diffuse", _diffuseSampler, _diffuse_map, "default_c.png") //d:\\Data\\textures
DECLARE_SAMPLER_2D("Normal", _normalSampler, _normal_map, "default_n.png")
DECLARE_SAMPLER_2D("Detail", _detailSampler, _detail_map, "default_n.png")
DECLARE_SAMPLER_2D("Gloss", _glossSampler, _gloss_map, "default_g.png")
DECLARE_SAMPLER_2D("Metal", _metalSampler, _metal_map, "default_m.png")
DECLARE_SAMPLER_2D("Emissive", _emissiveSampler, _emissive_map, "default_e.png")
DECLARE_SAMPLER_2D("Backscatter", _backscatterSampler, _backscatter_map, "default_b.png")

// Map Inverts
DECLARE_MATERIAL_VARIABLE("Invert Diffuse Map", _invert_diffuse_map, bool, false)
DECLARE_MATERIAL_VARIABLE("Invert Metal Map", _invert_metal_map, bool, false)
DECLARE_MATERIAL_VARIABLE("Invert Gloss Map", _invert_gloss_map, bool, false)
DECLARE_MATERIAL_VARIABLE("Invert Normap Map", _invert_normal_map, bool, false)
DECLARE_MATERIAL_VARIABLE("Invert Detail Map", _invert_detail_map, bool, false)
DECLARE_MATERIAL_VARIABLE("Invert Emissive Map", _invert_emissive_map, bool, false)

// Map Inverts
DECLARE_MATERIAL_VARIABLE("Advanced Diffuse Mat", _adv_diffuse_mat, bool, false)
DECLARE_MATERIAL_VARIABLE("Advanced Metal Mat", _adv_metal_mat, bool, false)
DECLARE_MATERIAL_VARIABLE("Advanced Gloss Mat", _adv_gloss_mat, bool, false)
DECLARE_MATERIAL_VARIABLE("Advanced Normap Mat", _adv_normal_mat, bool, false)
DECLARE_MATERIAL_VARIABLE("Advanced Detail Mat", _adv_detail_mat, bool, false)
DECLARE_MATERIAL_VARIABLE("Advanced Emissive Mat", _adv_emissive_mat, bool, false)

// Material Variables
DECLARE_MATERIAL_VARIABLE("Diffuse_Tint_Color", _diffuse_tint_color, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE_EX("Diffuse Desaturate", _diffuse_desaturate, float, 0.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Metal Map Component", _metal_comp, int, 0, 0, 3)
DECLARE_MATERIAL_VARIABLE_EX("Metal Map Value", _metal_value, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Gloss Map Component", _gloss_comp, int, 0, 0, 3)
/*
int _gloss_comp <
	string UIName = "Gloss Map Component";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 3.0f;	
>  = 0;
*/
DECLARE_MATERIAL_VARIABLE_EX("Gloss Map Value", _gloss_value, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Normal Map Scale", _normal_scale, float, 1.0f, 0.0f, 1.0f)
//DECLARE_MATERIAL_VARIABLE_EX("Normal Map Value", _normal_value, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Detail Oriented", _detail_oriented, bool, true)
DECLARE_MATERIAL_VARIABLE_EX("Detail Map Scale", _detail_scale, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Emissive Map Component", _emissive_comp, int, 0, 0, 3)
DECLARE_MATERIAL_VARIABLE_EX("Emissive Map Value", _emissive_value, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Backscatter Map Component", _backscatter_comp, int, 0, 0, 3)
DECLARE_MATERIAL_VARIABLE_EX("Environment Map Power", _environment_power, float, 1.0f, 0.0f, 1.0f)
//DECLARE_MATERIAL_VARIABLE("Diffuse Color", _diffuse_color, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Alpha Ref Value", _alpha_ref_value, float, 0.5f)
DECLARE_MATERIAL_VARIABLE("Vertex Wibble Enabled", _vertexWibbleEnabled, bool, false)
DECLARE_MATERIAL_VARIABLE("Wibble Amplitude", _amplitude, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Wibble Frequency", _frequency, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Wibble Phase", _phase, float4, float4(0.0f, 0.0f, 0.0f, 0.0f))
DECLARE_MATERIAL_VARIABLE("Wibble Flip Phase", _flipVertexPhase, bool, false)

DECLARE_MATERIAL_VARIABLE_EX("Default Tiling X", _def_tiling_x, float, 1.0f, -FLT_MAX, FLT_MAX)
DECLARE_MATERIAL_VARIABLE_EX("Default Tiling Y", _def_tiling_y, float, 1.0f, -FLT_MAX, FLT_MAX)
DECLARE_MATERIAL_VARIABLE_EX("Default Offset X", _def_offset_x, float, 0.0f, -FLT_MAX, FLT_MAX)
DECLARE_MATERIAL_VARIABLE_EX("Default Offset Y", _def_offset_y, float, 0.0f, -FLT_MAX, FLT_MAX)


struct VS_OUT 
{
	float4 Texcoord				: TEXCOORD0;
	float3 WorldPosition		: TEXCOORD1;
	float3 WorldNormal		: TEXCOORD2;
	float3 WorldTangent		: TEXCOORD3;
	float3 WorldBinormal		: TEXCOORD4;
	float4 Color					: TEXCOORD5;
	float4 HPosition				: SV_POSITION;
};

float4 Desaturate(float4 color, float desaturation)
{
    float3 grayXfer = PerceivedLuminance;
    float grayf = dot(grayXfer, color.xyz);
    float3 gray = float3(grayf, grayf, grayf);
    return float4(lerp(color.rgb, gray, desaturation), color.a);
}

VS_OUT std_VS(VS_IN In) 
{
	VS_OUT Out = (VS_OUT)0;
	Out.WorldNormal = mul(In.Normal,mWorldInverseTranspose).xyz;
	Out.WorldTangent = mul(In.Tangent,mWorldInverseTranspose).xyz;
	Out.WorldBinormal = mul(In.Binormal,mWorldInverseTranspose).xyz;	
	Out.WorldPosition = mul(float4(In.Position.xyz,1),mWorld).xyz;
	
	if (_vertexWibbleEnabled)
	{
		VertexWibble(_frequency.xyz, _phase.xyz, _amplitude.xyz, _flipVertexPhase, In.Color.rgb, In.Alpha.x, Out.WorldPosition, Out.Color);
		if (ShouldAnimateVertex())
		{
			float4 vViewPosition = mul(float4(Out.WorldPosition, 1), mView);
			Out.HPosition = mul(vViewPosition, mProjection);
		}
		else
		{
			Out.HPosition = mul(float4(In.Position.xyz,1), mWorldViewProj);
		}
	}
	else
	{
		Out.Color = float4(In.Color, In.Alpha.x) * _use_vertex_color + _diffuse_color;
		Out.HPosition = mul(float4(In.Position.xyz,1), mWorldViewProj);
	}

	// Pass through the UVs
	Out.Texcoord.xy = CalcTextureCoord(In.Texcoord.xy, float2(_def_tiling_x, _def_tiling_y), float2(_def_offset_x, _def_offset_y));
	Out.Texcoord.zw = CalcTexCoord(In.Texcoord.xy, _adv_mat_x.xy, _adv_mat_y.xy, _adv_mat_z.xy, _adv_mat_w.xy);
	return Out;
}

float4 std_PS(uniform bool bAlphaBlend,
			uniform bool bAlphaTest,
			VS_OUT In) : COLOR
{
	float2 def_coords = In.Texcoord.xy;
	float2 adv_coords = In.Texcoord.zw;

	float4 vAlbedo = _use_diffuse_map ? InvertValue(tex2D(_diffuseSampler, _adv_diffuse_mat ? adv_coords : def_coords), _invert_diffuse_map) : float4(1,1,1,1);
	vAlbedo = Desaturate(vAlbedo, _diffuse_desaturate);
	vAlbedo.rgb *= In.Color.rgb;
	
	if (bAlphaTest)
	{
		clip(vAlbedo.a - _alpha_ref_value - 1.0f + In.Color.a);
	}
	
	float fGloss = _use_gloss_map ? InvertValue(tex2D(_glossSampler, _adv_gloss_mat ? adv_coords : def_coords)[_gloss_comp], _invert_gloss_map) : 1.0f;
	fGloss *= _gloss_value;

	float fMetal = _use_metal_map ? InvertValue(tex2D(_metalSampler, _adv_metal_mat ? adv_coords : def_coords)[_metal_comp], _invert_metal_map) : 1.0f;
	fMetal *= _metal_value;

	float fEmissive = _use_emissive_map ? InvertValue(tex2D(_emissiveSampler, _adv_emissive_mat ? adv_coords : def_coords)[_emissive_comp], _invert_emissive_map) : 1.0f;
	fEmissive *= _emissive_value;

	float fBackscatter = _use_backscatter_map ? tex2D(_backscatterSampler, In.Texcoord.xy)[_backscatter_comp] : 0.0f;

	float3 vNormal = In.WorldNormal;
	float2 n1 = float2(0,0);
	float2 n2;

	if (_use_normal_map)
	{
		n1 = (InvertValue(tex2D(_normalSampler, _adv_normal_mat ? adv_coords : def_coords), _invert_normal_map).xy * 2.0f - 1.0f) * _normal_scale;
	}
	if (_use_detail_map)
	{
		n2 = (InvertValue(tex2D(_detailSampler, _adv_detail_mat ? adv_coords : def_coords), _invert_detail_map).xy * 2.0f - 1.0f) * _detail_scale;
		if (_use_normal_map)
		{
			if (!_detail_oriented)
			{
				float2 r = n1 + n2;
				n1 = r;
			}
			else 
			{
				/************* Reoriented normal map blending **********************

				float3 v1 = (InvertValue(tex2D(_normalSampler, _adv_normal_mat ? adv_coords : def_coords), _invert_normal_map)) * float3(2, 2, 2) + float3(-1, -1,  0);
				//v1 *= _normal_scale;
				float3 v2 = (InvertValue(tex2D(_detailSampler, _adv_detail_mat ? adv_coords : def_coords), _invert_detail_map)) * float3(-2, -2, 2) + float3( 1,  1, -1);
				//v2 *= _detail_scale;
				float3 normal  = v1 * dot(v1, v2) * _normal_scale/ v1.z - v2 * _detail_scale;

				n1 = normal.xy;

				********************************************************************/

				/*
				float a = 1/(1 + vNormal.z);
				float b = -vNormal.x * vNormal.y * a;

				// Form a basis
				float3 b1 = float3(1 - vNormal.x * vNormal.x * a, b, -vNormal.x);
				float3 b2 = float3(b, 1 - vNormal.y * vNormal.y * a, -vNormal.y);
				float3 b3 = vNormal;

				if (vNormal.z < -0.9999999f) // Handle the singularity
				{
					b1 = float3( 0, -1, 0);
					b2 = float3(-1,  0, 0);
				}

				// Rotate n2 via the basis
				r = vDetail.x * b1 + vDetail.y * b2 + vDetail.z * b3;


				float3x3 nBasis = 
				{
					{ n1.z, n1.y, -n1.x }, // +90 degree rotation around y axis
					{ n1.x, n1.z, -n1.y }, // -90 degree rotation around x axis
					{ n1.x, n1.y,  n1.z }
				};

				float3 r = (n2.x*nBasis[0] + n2.y*nBasis[1] + abs(n2.z)*nBasis[2]);
				*/
				
				float z1 = sqrt(1 - n1.x*n1.x - n1.y*n1.y);
				float z2 = sqrt(1 - n2.x*n2.x - n2.y*n2.y);

				float3x3 nBasis = 
				{
					{ z1, n1.y, -n1.x }, // +90 degree rotation around y axis
					{ n1.x, z1, -n1.y }, // -90 degree rotation around x axis
					{ n1.x, n1.y,  z1 }
				};

				float2 r = (n2.x*nBasis[0] + n2.y*nBasis[1] + abs(z2)*nBasis[2]).xy;
				n1 = r;
			}
		}
		else n1 = n2;
	}

	ApplyBumpMapping(n1.xy, In.WorldTangent, In.WorldBinormal, vNormal);

	float3 vView = normalize(mViewInverse[3].xyz - In.WorldPosition);
	float fNdotV = saturate( dot(vNormal, vView) );

	vAlbedo.rgb = vAlbedo.rgb * vAlbedo.rgb;

	float3 vDiffuseColor = lerp(vAlbedo.rgb + _diffuse_tint_color.rgb, 0.0f, fMetal);
	float3 vSpecularColor = lerp(0.05f, vAlbedo.rgb, fMetal);

	float3 vSpecularLighting = 0;
	float3 vAmbientColor = _ambient_color.xyz;
	float3 vDiffuseLighting = 0;
	float3 vEdgeLighting = 0;
	
	float3 vFinalColor = 0;
	float3 lightDir = normalize(vLightDirection.xyz);
	
	if (_use_physics_based)
	{
		DirectionalLight(vNormal, vView, lightDir, vLightColor, vSpecularColor, fGloss, vDiffuseLighting, vSpecularLighting);
		if (_use_environment_map)
		{
			EnvironmentLight(vNormal, vView, fNdotV, vSpecularColor, fGloss * _environment_power, vDiffuseLighting, vSpecularLighting);
		}
		//vFinalColor = vDiffuseLighting * vDiffuseColor + vSpecularLighting + fEmissive * vAlbedo.rgb;
		vFinalColor = vDiffuseLighting * vDiffuseColor + vSpecularLighting + vAlbedo.rgb;
	}
	else
	{
		DirectionalLight(vNormal, vView, lightDir, vLightColor, vSpecularColor, fGloss, vDiffuseLighting, vSpecularLighting);
		if (_use_environment_map)
		{
			EnvironmentLight(vNormal, vView, fNdotV, vSpecularColor, fGloss * _environment_power, vDiffuseLighting, vSpecularLighting);
		}
		float3 pbrFinalColor = vDiffuseLighting * vDiffuseColor + vSpecularLighting;
	
	
		float3 dAmbientColor = _ambient_color.xyz;
		//float3 dDiffuseColor = _use_additive_lighting ? vDiffuseColor : (_use_diffuse_map ? vAlbedo.rgb : _diffuse_color.xyz);
		//float3 dSpecularColor = _use_additive_lighting ? vSpecularColor : (_use_metal_map ? float3(fMetal,fMetal,fMetal) : _specular_color.xyz);
		
		float3 dDiffuseColor = _use_diffuse_map ? vAlbedo.rgb : _diffuse_color.xyz;
		float3 dSpecularColor = _specular_color.xyz;
		
		float3 pbr = _use_additive_lighting ? float3(1.0f,fGloss,fMetal) : float3(1.0f, CookTorrance_Roughness, CookTorrance_Fresnel_Max);
	
		vFinalColor = LightIt(vNormal, vView, lightDir, vLightColor, dDiffuseColor, dSpecularColor, dAmbientColor, 
			float3(1.0f,1.0f,1.0f), 
			In.WorldTangent, 
			In.WorldBinormal,  
			1.0f,
			pbr, 
			vDiffuseLighting,
			vSpecularLighting,
			vEdgeLighting);

		if (_use_environment_map)
		{
			EnvironmentLight(vNormal, vView, fNdotV, vSpecularColor, fGloss * _environment_power, vDiffuseLighting, vSpecularLighting);
		}
		//if (_use_physics_combo) vFinalColor = vDiffuseLighting * dDiffuseColor + vSpecularLighting + fEmissive * vAlbedo.rgb;
		if (_use_physics_combo) vFinalColor = lerp(vFinalColor, pbrFinalColor, fEmissive.r);
		
	}
	
	return tonemap(float4(vFinalColor, bAlphaBlend ? vAlbedo.a : 0.0f));
}

// Technique Settings
DECLARE_MATERIAL_VARIABLE("Alpha Blend Enabled", _alpha_blend, bool, false)
DECLARE_MATERIAL_VARIABLE("Alpha Test Enabled", _alpha_test, bool, false)

#include "../Common/Techniques.hlsli"

BlendState CustAlphaBlending
{
	BlendEnable[0] = TRUE;
	SrcBlend[0] = SRC_ALPHA;
	DestBlend[0] = INV_SRC_ALPHA;
	BlendOp[0] = ADD;
	SrcBlendAlpha[0] = ONE; //ZERO
	DestBlendAlpha[0] = ONE; //INV_SRC_ALPHA
	BlendOpAlpha[0] = ADD;
	RenderTargetWriteMask[0] = 0x0F;
};

technique11 Custom <
	string Script = "Pass=p0;";
> {
	pass p0 <
		string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( CustAlphaBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );

		SetRasterizerState( NoCull );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(_alpha_blend, _alpha_test)));
	}
}
