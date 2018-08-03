#ifndef COMMON
	#include "Common.hlsli"
#endif 

// Light usuge

DECLARE_MATERIAL_VARIABLE("Use_Specular", Use_Specular, bool, true)
DECLARE_MATERIAL_VARIABLE("Ambient_Color", _ambient_color, float4, float4(0.3f, 0.3f, 0.3f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Diffuse_Color", _diffuse_color, float4, float4(0.3f, 0.3f, 0.3f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Specular_Color", _specular_color, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))

DECLARE_MATERIAL_VARIABLE("Use_Vertex_Color", _use_vertex_color, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Physics_Based", _use_physics_based, bool, true)
DECLARE_MATERIAL_VARIABLE("Use_Physics_Combo", _use_physics_combo, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Additive_Lighting", _use_additive_lighting, bool, true)
DECLARE_MATERIAL_VARIABLE("Use_Lambert", Use_Lambert, bool, true)
DECLARE_MATERIAL_VARIABLE("Use_OrenNayar", Use_OrenNayar, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Minnaert", Use_Minnaert, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Phong", Use_Phong, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Gaussian", Use_Gaussian, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_BackSpec", Use_BackSpec, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Blinn", Use_Blinn, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Glossy", Use_Glossy, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_CookTorrance", Use_CookTorrance, bool, false)
DECLARE_MATERIAL_VARIABLE("Use_Ward", Use_Ward, bool, false)

// Lighting Variables

DECLARE_MATERIAL_VARIABLE("Lambert_Wrap", Lambert_Wrap, float, 0.0f)
DECLARE_MATERIAL_VARIABLE_EX("OrenNayar_Roughness", OrenNayar_Roughness, float, 0.4f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Minnaert_Darkness", Minnaert_Darkness, float, 0.4f)
DECLARE_MATERIAL_VARIABLE("Minnaert_Brightness", Minnaert_Brightness, float, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Minnaert_Sharpness", Minnaert_Sharpness, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Phong_Power", Phong_Power, float, 20.0f)
DECLARE_MATERIAL_VARIABLE("Phong_Wrap", Phong_Wrap, float, 0.0f)
DECLARE_MATERIAL_VARIABLE_EX("Gaussian_Roughness", Gaussian_Roughness, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Gaussian_Brightness", Gaussian_Brightness, float, 3.0f)
DECLARE_MATERIAL_VARIABLE("BackSpec_Power", BackSpec_Power, float, 3.0f)
DECLARE_MATERIAL_VARIABLE_EX("BackSpec_Factor", BackSpec_Factor, float, 0.8f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("BackSpec_Light", BackSpec_Light, bool, true)
DECLARE_MATERIAL_VARIABLE("BackSpec_Tint", BackSpec_Tint, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE_EX("Blinn_Eccentricity", Blinn_Eccentricity, float, 0.4f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Blinn_Rolloff", Blinn_Rolloff, float, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Glossy_Roughness", Glossy_Roughness, float, 0.5f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Glossy_Brightness", Glossy_Brightness, float, 0.72f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Glossy_Sharpness", Glossy_Sharpness, float, 0.4f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("CookTorrance_Roughness", CookTorrance_Roughness, float, 0.5f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("CookTorrance_Smoothness", CookTorrance_Smoothness, float, 0.4f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("CookTorrance_Orientation", CookTorrance_Orientation, bool, true)
DECLARE_MATERIAL_VARIABLE_EX("CookTorrance_Fresnel_Min", CookTorrance_Fresnel_Min, float, 0.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("CookTorrance_Fresnel_Max", CookTorrance_Fresnel_Max, float, 1.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Ward_Intensity", Ward_Intensity, float, 0.0f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE("Ward_Orientation", Ward_Orientation, float, 0.0f)
DECLARE_MATERIAL_VARIABLE_EX("Ward_RoughnessX", Ward_RoughnessX, float, 0.5f, 0.0f, 1.0f)
DECLARE_MATERIAL_VARIABLE_EX("Ward_RoughnessY", Ward_RoughnessY, float, 0.5f, 0.0f, 1.0f)

DECLARE_MATERIAL_VARIABLE("Use_Edge", Use_Edge, bool, false)
DECLARE_MATERIAL_VARIABLE("Edge_Multiply", Edge_Multiply, bool, false)
DECLARE_MATERIAL_VARIABLE("Edge_Color", Edge_Color, float4, float4(1.0f, 1.0f, 1.0f, 1.0f))
DECLARE_MATERIAL_VARIABLE("Edge_Power", Edge_Power, float, 3.0f)
DECLARE_MATERIAL_VARIABLE("Edge_Wrap", Edge_Wrap, float, 0.0f)
DECLARE_MATERIAL_VARIABLE("Edge_Light_Based", Edge_Light_Based, bool, false)

float GaussianSpec (float3 halfDir, float3 norm, float roughness, float brightness)
{
	float i = 0;
	if (roughness) {
		float HdotN = dot(halfDir,norm);
		float k = (1.0 - HdotN)/roughness;
		i = exp(-(k*k));
		i = lerp(i*(1-HdotN), i, brightness);
	}
	return i;
}

float PhongSpecular (float3 halfDir, float3 normal, float power, float wrap)
{
	float HdotN = saturate(dot(halfDir,normal));

	float i = (HdotN < 0) ? 0 : pow(abs((HdotN + wrap)/(1 + wrap)), power); 
	return i;
}

float BacklightSpecular (float3 halfDir, float3 normal, float power, float factor)
{
	float HdotN = dot(halfDir,normal);
	float a = pow(max(1.0 - HdotN,0), power)*factor;
	return a;
}

float BackviewSpecular (float3 view, float3 normal, float power, float factor)
{
	float VdotN = dot(view,normal);
	float a = pow(max(1.0 - abs(VdotN),0), power)*factor;
	return a;
}

float LocalIllumGlossy (float3 halfDir, float3 normal, float roughness, float sharpness, float brightness)
{
    float w = (1-brightness)*(1-sharpness);
	return lerp(max(0, brightness-w), min(brightness+w, 1), pow(max(0,dot(normal,halfDir)), 1/roughness));
}

float CookTorranceSpec(float3 halfDir, float3 view, float3 norm, float hard)
{
	float VdotN = max(0,dot(view,norm));
	VdotN = sqrt(1.0 - VdotN*VdotN);
//	float Nn3 = faceforward(normalize(norm), -view);
	float HdotN = max(0,dot(halfDir,norm));
	HdotN = sqrt(1.0 - HdotN*HdotN);
	float i = pow(HdotN, hard);
	
	return (i/(0.1+VdotN));
}

float CookTorranceSpecular (float3 light, float3 view, float3 norm, float roughness, float smoothness, float minFresnel, float maxFresnel, bool orientation) 
{
	float i = 0;
	if (roughness) 
	{
		float3 LN = normalize(light);
		float3 VN = normalize(view);
//		float3 NN = faceforward(norm, -view, norm);
	
		float VdotN = dot(VN,norm);
		float LdotN = dot(LN,norm);
	
		float3 halfDir = normalize(VN + LN);
		float HdotN = dot(halfDir,norm);
		float HdotV = (!orientation) ? dot(halfDir,VN) : 1.0;
	
		float m2 = roughness*roughness;
		float t = HdotN;
		float t2 = t*t;
		float v = VdotN;
		float vp = LdotN;
		float u = HdotV;
	
		float D = 0.5/(m2*t2*t2)*exp((t2-1)/(m2*t2));
		float G = (!orientation) ? min(1, 2*min(t*v/u, t*vp/u)) : min(1, 2*t*vp/u);
//		float G = min(1, 2*min(t*v/u, t*vp/u));
		
		float F = 1.0 - abs((!orientation) ? v : vp);
		F = lerp(minFresnel,maxFresnel,F);
		
//		float F = pow(1+v, refraction);
		i = (D*F*G)/v;
		i = lerp(i*(1-t2), i, smoothness);		
//		if (reverse) { i = -i; }
	}
	return i;
}

float LambertAmbient(float3 light, float3 normal, float wrap = 1) 
{
	float NdotL = saturate(dot(normal,normalize(light))); 
	return (NdotL + wrap)/(1 + wrap);
}
float OrenNayarDiffuse(float3 light, float3 view, float3 norm, float roughness) 
{
 	float3 LN = normalize(light);
	float VdotN = max(0,dot(view,norm));
	float LdotN = max(0,dot(LN,norm));

	float cos_theta_i = LdotN;
	float theta_r = acos(VdotN);
	float theta_i = acos(cos_theta_i);
	float alpha = max(theta_i, theta_r);	
	float beta = min(theta_i, theta_r)*0.95;
	float sigma2 = roughness*roughness;

	float A = 1.0 - 0.5*sigma2/(sigma2+0.33);	
	float B = 0;

	float3 VperpN = normalize (view-norm*VdotN);
	float3 LperpN = normalize (LN-norm*LdotN);
	
	float cos_phi_diff = dot(VperpN, LperpN);
	if (cos_phi_diff >= 0) 
	{
		B = 0.45*sigma2/(sigma2+0.09);
		B *= sin(alpha)*tan(beta)*max(0,cos_phi_diff);
	}
	return cos_theta_i*(A + B);
}

float MinnaertDiffuse(float3 light, float3 view, float3 norm, float darkness, float brightness, float sharpness = 1) 
{
 	float i = 0;
	float3 LN = normalize(light);
	float VdotN = max(0,dot(view,norm));
	float LdotN = max(0,dot(LN,norm));

	LdotN = lerp(LdotN, 1, 1 - sharpness);
	
	float cos_theta_i = LdotN;
	
	if (darkness <= 1.0)
		i = cos_theta_i * pow(max(VdotN*LdotN, 0.1), darkness-1.0); /*The Real model*/
	else
		i = cos_theta_i * pow(max(1.001-VdotN, 0.001), darkness-1.0); /*Nvidia model*/
	
	return max(0,i*brightness);
}

float BlinnSpec(float3 light, float3 view, float3 norm, float eccentricity, float rolloff) 
{
	float3 V = view;
	float3 N = norm;
	float  dotNV = dot(N, V);

	float  ecc = eccentricity*eccentricity - 1.0;

	float3 L = light;
	float3 H = normalize(view + light);

	float  dotNL = dot(N, L);
	float  dotNH = dot(N, H);
	float  dotVH = dot(V, H);

	float D = ( ecc + 1 ) / ( 1 + ecc * dotNH * dotNH );
	D *= D;
	dotNH *= 2;

	float G;
	G = (dotNV < dotNL)
		? (dotNV * dotNH < dotVH) ? dotNH / dotVH : 1 / dotNV
		: (dotNL * dotNH < dotVH) ? dotNL * dotNH / (dotVH * dotNV) : 1 / dotNV;

	dotVH = pow(1 - dotVH, 3);
	float F = dotVH + (1 - dotVH)*rolloff;
	float i = (dotNL > 0) ? D*G*F : 0;
	
	return i;	
}

float3 RotatePointAroundVector (float3 pos, float3 vect, float angle) 
{
	float x = pos.x;	
	float y = pos.y;	
	float z = pos.z;
	
	float u = vect.x;	
	float v = vect.y;	
	float w = vect.z;

	float ux = u*x;
	float uy = u*y;
	float uz = u*z;

	float vx = v*x;
	float vy = v*y;
	float vz = v*z;

	float wx = w*x;
	float wy = w*y;
	float wz = w*z;

	float vv = v*v;
	float uu = u*u;
	float ww = w*w;	
	
	float sang, cang;
	sincos(angle,sang, cang);
	
	float new_x = u*(ux+vy+wz) + (x*(vv+ww) - u*(vy+wz))*cang  + (-wy+vz)*sang; 
	float new_y = v*(ux+vy+wz) + (y*(uu+ww) - v*(ux+wz))*cang  + (wx-uz)*sang; 
	float new_z = w*(ux+vy+wz) + (z*(uu+vv) - w*(ux+vy))*cang  + (-vx+uy)*sang; 
	
	return (float3 (new_x,new_y,new_z));
}

float3 PairVectorTransit (float3 pos, float3 vect1, float3 vect2) 
{
	float3 v1 = normalize(vect1);
	float3 v2 = normalize(vect2);
 
	float3 vect = normalize (cross (v1, v2));
	float angle = acos (dot (v1, v2));
	
	return RotatePointAroundVector(pos,vect,angle);
}

float WardAnisotropic (float3 halfDir, float3 light, float3 view, float3 normal, float intensity, float xroughness, float yroughness, float angle, float3 tangent, float3 binormal) 
{
	float i = 0;
	
	float3 LN = normalize(light);
	float cos_theta_i = dot(LN,normal);
	
	if (cos_theta_i > 0.0) {
		float xr = max(0.00001,xroughness);
		float yr = max(0.00001,yroughness);

		float cos_theta_r = max(0.0001, dot(normal,view));

		float3 T = RotatePointAroundVector (tangent, normal, angle);
		float3 B = normalize(cross(normal,T));
		float3 X = T/xr;
		float3 Y = B/yr;
			
		float XdotH = dot(X,halfDir);
		float YdotH = dot(Y,halfDir);
		float HdotN = dot(halfDir,normal);
		float rho = exp (-(XdotH*XdotH + YdotH*YdotH)/(1 + HdotN))/sqrt(cos_theta_i*cos_theta_r);
		i = (cos_theta_i*rho);
	}
	return (i*intensity);
}

float3 myRefraction (float3 view, float3 normal, float thickness)
{	
	float pi = 3.14159;
	float VdotN = dot(view,normal);	
	float3 lamRGB = float3(6,5,4);
	float3 offsetRGB = float3(0,0,0);
	float3 vd = 60;
//	float k = exp(-(1+VdotN));
	float k = 1/VdotN;

	float3 ang = (2*pi*vd/lamRGB)*thickness*k + 0.5*pi + offsetRGB;

	return 0.5*(sin(ang)+1);
}
//
float3 LightIt(float3 normal, 
			float3 camDir,
			float3 vLightDirection,
			float3 vLightColor,
			float3 vDiffuseColor,
			float3 vSpecularColor, 
			float3 vAmbientColor, 
			float3 reflection, 
			float3 tangent, 
			float3 binormal,  
			float emission,
			float3 pbr,
			inout float3 vDiffuseLighting,
			inout float3 vSpecularLighting,
			inout float3 vEdgeLighting)
{
	vDiffuseLighting = float3(1,1,1);
	vSpecularLighting = 0;
	vEdgeLighting = 0;

	// Simple lighting for max.
	
	vDiffuseLighting = vAmbientColor;
	vSpecularLighting = 0;
	float c = 0;
	float k = 0;
	float b = 0;
	float w = 0;

	float3 halfDir = normalize(camDir + vLightDirection);
	float HdotN = dot(halfDir,normal);
	float VdotN = dot(camDir,normal);
		
	k += float(Use_Lambert)		  * LambertAmbient(vLightDirection, normal, Lambert_Wrap);
	k += float(Use_OrenNayar)	  * OrenNayarDiffuse (vLightDirection, camDir, normal, OrenNayar_Roughness);
	k += float(Use_Minnaert)	  * MinnaertDiffuse (vLightDirection, camDir, normal, Minnaert_Darkness, Minnaert_Brightness, Minnaert_Sharpness);
	
	c += float(Use_Phong)		  * PhongSpecular (halfDir, normal, Phong_Power, Phong_Wrap);
	c += float(Use_Gaussian)	  * GaussianSpec (halfDir, normal, Gaussian_Roughness, Gaussian_Brightness);
	b  = float(Use_BackSpec)	  * (
										(BackSpec_Light) 
										? BacklightSpecular (halfDir, normal, BackSpec_Power, BackSpec_Factor)
										: BackviewSpecular (camDir, normal, BackSpec_Power, BackSpec_Factor)
									);
	c += b;
	c += float(Use_Blinn)		  * BlinnSpec (vLightDirection, camDir, normal, Blinn_Eccentricity, Blinn_Rolloff);
	c += float(Use_Glossy)		  * LocalIllumGlossy (halfDir, normal, Glossy_Roughness, Glossy_Sharpness, Glossy_Brightness);

	float cooktortance_roughness =  pbr.g; //CookTorrance_Roughness;
	float cooktorrance_fresnel_max = pbr.b; //CookTorrance_Fresnel_Max;
	c += float(Use_CookTorrance)  * CookTorranceSpecular (vLightDirection, camDir, normal, cooktortance_roughness, CookTorrance_Smoothness, CookTorrance_Fresnel_Min, cooktorrance_fresnel_max, CookTorrance_Orientation);		
	w  = float(Use_Ward)		  * WardAnisotropic (halfDir, vLightDirection, camDir, normal, Ward_Intensity, Ward_RoughnessX, Ward_RoughnessY, Ward_Orientation, tangent, binormal);		
	c += w;
//	c += float(Use_OrenNayarSpec) * OrenNayarDiffuse (halfDir, camDir, normal, OrenNayar_Roughness);

	vDiffuseLighting += k * vLightColor;
	vSpecularLighting += c * vLightColor;

	float3 col = vDiffuseColor*lerp(1, vDiffuseLighting, emission);

	if(Use_Specular) 
	{
		col += vSpecularLighting * vSpecularColor * emission;
		col += b*BackSpec_Tint.xyz*emission;
	}
	
	if (Use_Edge) 
	{
		float edge = (Edge_Light_Based) ? HdotN : abs(VdotN);
		edge = (edge + Edge_Wrap*Edge_Wrap)/(1 + Edge_Wrap*Edge_Wrap);

		float fresnel = 1;		
/*
		if (Use_Fresnel) 
		{
			fresnel = 1.0 - abs(dot(camDir,normal)); 
			edge = (edge < Fresnel_Min) ? 0 : edge;
			edge = (edge > Fresnel_Max) ? 1 : edge;
//			fresnel = lerp(Fresnel_Min, Fresnel_Max, fresnel);
//			fresnel = clamp(edge, Fresnel_Min, Fresnel_Max);
		}
*/
			
	//	float edge = (Edge_Light_Based) ? 1.0 - HdotN : 1.0 - abs(VdotN); 

		if (!Edge_Multiply) 
		{
			edge = 1.0 - edge; 
			vEdgeLighting += pow(abs(edge),Edge_Power) * reflection * vLightColor;
			col += vEdgeLighting * Edge_Color.xyz;
		}
		else 
		{
			col += vEdgeLighting;
			col = lerp(Edge_Color.xyz * reflection * vLightColor, col, edge);
			col *= Edge_Color.xyz * reflection * vLightColor * pow(edge,Edge_Power);
		}
	}

	return  col;
}

