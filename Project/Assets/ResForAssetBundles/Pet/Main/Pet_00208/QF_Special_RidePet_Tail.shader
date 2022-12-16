// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QF/QF_Special_RidePet_Tail"
{
	Properties
	{
		_Float3("2U的渐变强度", Float) = 1
		_Float5("半透明强度", Float) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Float0("主图受Noise影响程度", Float) = 0
		_Intensity("Intensity", Float) = 0
		_Power("Power", Float) = 1
		_FresnelNormalTex("Fresnel Normal Tex", 2D) = "bump" {}
		[HDR]_Color1("外圈颜色", Color) = (1,1,1,1)
		_FresnelPower("FresnelPower", Float) = 1
		_shichatex("视差纹理(RGB）Clamp", 2D) = "black" {}
		_Float4("旋转", Float) = 0
		_Tex0SpeedU2("SpeedU", Float) = 0
		_Tex0SpeedV2("Speed V", Float) = 0
		[HDR]_Color2("Color", Color) = (0,0,0,1)
		_Scale("视差Scale", Float) = 0
		_Tex3("底图", 2D) = "black" {}
		_Float2("底图受Noise影响程度", Float) = 0
		[HDR]_Color3("Color", Color) = (0,0,0,1)
		_Tex01SpeedU1("底图SpeedU", Float) = 0
		_Tex01SpeedV1("底图1Speed V", Float) = 0
		_TexSample03("Tex Sample 03", 2D) = "black" {}
		_Float1("Tex Sample 03受Noise影响程度", Float) = 0
		[HDR]_TexSample03Color("Tex Sample 03Color", Color) = (0,0,0,0)
		_SpeedU("SpeedU", Float) = 0
		_SpeedV("SpeedV", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseIntensity("Noise Intensity", Float) = 0
		_NoiseSpeedV("Noise Speed V", Float) = 0
		_NoiseSpeedU("Noise Speed U", Float) = 0
		_Float6("尾巴纹路Power", Float) = 0
		_Float7("尾巴纹路强度", Float) = 5.67
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
        #include "Lighting.cginc"

		struct Input
		{
			float2 uv2_texcoord2;
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
			float3 worldViewDir;

			half3 TtoW0;
			half3 TtoW1;
			half3 TtoW2;
		};

		struct appdata
		{
			float4 pos : POSITION;
			half3 normal : NORMAL;
			half4 tangent : TANGENT;
			half2 uv : TEXCOORD0;
			half2 uv1 : TEXCOORD1;
		};

		struct v2f_surf {
			float4 pos : SV_POSITION;

			half2 uv : TEXCOORD0;
			half4 TtoW0 : TEXCOORD1;
			half4 TtoW1 : TEXCOORD2;
			half4 TtoW2 : TEXCOORD3;
			half3 tangentViewDir : TEXCOORD4; //切线空间视角方向
			half3 worldViewDir: TEXCOORD5;
			half3 lightDir : TEXCOORD6;
			half2 uv1 : TEXCOORD7;
		};

		uniform sampler2D _MainTex;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _NoiseSpeedU;
		uniform float _NoiseSpeedV;
		uniform float _NoiseIntensity;
		uniform float _Float0;
		uniform float4 _MainTex_ST;
		uniform float _Power;
		uniform float _Intensity;
		uniform float _Float3;
		uniform sampler2D _shichatex;
		uniform float _Tex0SpeedU2;
		uniform float _Tex0SpeedV2;
		uniform float4 _shichatex_ST;
		uniform float _Float4;
		uniform float _Scale;
		uniform float4 _Color2;
		uniform sampler2D _FresnelNormalTex;
		uniform float4 _FresnelNormalTex_ST;
		uniform float _FresnelPower;
		uniform float4 _Color1;
		uniform sampler2D _Tex3;
		uniform float4 _Tex3_ST;
		uniform float _Float2;
		uniform float _Tex01SpeedU1;
		uniform float _Tex01SpeedV1;
		uniform float4 _Color3;
		uniform sampler2D _TexSample03;
		uniform float _Float1;
		uniform float4 _TexSample03_ST;
		uniform float _SpeedU;
		uniform float _SpeedV;
		uniform float4 _TexSample03Color;
		uniform float _Float6;
		uniform float _Float7;
		uniform float _Float5;

		void surf(Input i , inout SurfaceOutput o)
		{
			o.Normal = float3(0,0,1);
			float2 uv1_Noise = i.uv2_texcoord2 * _Noise_ST.xy + _Noise_ST.zw;
			float noise = (tex2D(_Noise, (uv1_Noise + (half2(_NoiseSpeedU, _NoiseSpeedV) * _Time.y))).r * _NoiseIntensity);
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 mainTexColor = tex2D(_MainTex, ((noise * _Float0) + uv0_MainTex));
			float4 mainTex = (pow(mainTexColor, (_Power).xxxx) * _Intensity);
			float gradient = pow(i.uv2_texcoord2.x , _Float3);
			float2 uv1Parallax = i.uv2_texcoord2 * _shichatex_ST.xy + _shichatex_ST.zw;
			float cos360 = cos(_Float4);
			float sin360 = sin(_Float4);
			float2 rotator360 = mul(uv1Parallax - float2(0.5,0.5) , float2x2(cos360 , -sin360 , sin360 , cos360)) + float2(0.5,0.5);
			float2 panner317 = (1.0 * _Time.y * half2(_Tex0SpeedU2, _Tex0SpeedV2) + (rotator360 + noise));
			float2 uv_shichatex = i.uv_texcoord * _shichatex_ST.xy + _shichatex_ST.zw;
			float2 Offset262 = ((tex2D(_shichatex, uv_shichatex).r - 1) * normalize(i.viewDir).xy * _Scale) + panner317;
			float4 shicha255 = (tex2D(_shichatex, Offset262) * _Color2);
			float2 uv_FresnelNormalTex = i.uv_texcoord * _FresnelNormalTex_ST.xy + _FresnelNormalTex_ST.zw;
			o.Normal = UnpackNormal(tex2D(_FresnelNormalTex, uv_FresnelNormalTex));
			half3 w_normal = normalize(half3(dot(i.TtoW0.xyz, o.Normal), dot(i.TtoW1.xyz, o.Normal), dot(i.TtoW2.xyz, o.Normal)));
			half NdotV = dot(w_normal, i.worldViewDir);
			float4 fresnelColor = ((saturate(pow((1.0 - NdotV) , _FresnelPower)) * _Color1) * gradient);
			float2 uv1_Tex3 = i.uv2_texcoord2 * _Tex3_ST.xy + _Tex3_ST.zw;
			float4 _Tex3254 = (tex2D(_Tex3, ((uv1_Tex3 + (_Float2 * noise)) + (half2(_Tex01SpeedU1, _Tex01SpeedV1) * _Time.y))) * _Color3);
			float2 uv1_TexSample03 = i.uv2_texcoord2 * _TexSample03_ST.xy + _TexSample03_ST.zw;
			float2 appendResult224 = (float2(_SpeedU , _SpeedV));
			float4 TexSample03198 = (tex2D(_TexSample03, (((noise * _Float1) + uv1_TexSample03) + (appendResult224 * _Time.y))) * _TexSample03Color);
			o.Emission = (((mainTex * gradient) + shicha255 + fresnelColor + _Tex3254 + TexSample03198) + (saturate(pow(mainTexColor.r , _Float6)) * mainTex * _Tex3254 * _Float7)).rgb;
			o.Alpha = saturate((gradient * _Float5));
		}


		float4 FastObjectToClipPos(float3 v)
		{
			float4x4 Mt = transpose(unity_ObjectToWorld);
			float4x4 VPt = transpose(unity_MatrixVP);
			float3 r1 = Mt[0].xyz * v.xxx + Mt[3].xyz;
			r1 = Mt[1].xyz * v.yyy + r1.xyz;
			r1 = Mt[2].xyz * v.zzz + r1.xyz;
			float4 r2 = VPt[0].xyzw * r1.xxxx + VPt[3].xyzw;
			r2 = VPt[1].xyzw * r1.yyyy + r2.xyzw;
			r2 = VPt[2].xyzw * r1.zzzz + r2.xyzw;
			return r2;
		}

		v2f_surf vert_surf(appdata v) {
			v2f_surf o;

			o.pos = FastObjectToClipPos(v.pos.xyz);

			//o.pos = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(v.pos.xyz, 1.0)));
			o.uv.xy = v.uv;
			o.uv1.xy = v.uv1;

			half3 w_pos = mul(unity_ObjectToWorld, v.pos);
			half3 binormal = cross(v.tangent.xyz, v.normal);
			half3x3 tbn = half3x3(v.tangent.xyz, binormal, v.normal);
			// get cam pos in texture (TBN) space
			half3 camPosLocal = mul(unity_WorldToObject, half4(_WorldSpaceCameraPos, 1.0)).xyz;
			half3 dirToCamLocal = camPosLocal - v.pos;
			o.tangentViewDir = mul(tbn, dirToCamLocal);
			o.worldViewDir = UnityWorldSpaceViewDir(w_pos);
			o.lightDir = UnityWorldSpaceLightDir(w_pos);

			half3 w_normal = UnityObjectToWorldNormal(v.normal);
			half3 w_tangent = UnityObjectToWorldDir(v.tangent.xyz);
			half3 w_binormal = cross(w_normal, w_tangent) * v.tangent.w;

			o.TtoW0 = half4(w_tangent.x, w_binormal.x, w_normal.x, w_pos.x);
			o.TtoW1 = half4(w_tangent.y, w_binormal.y, w_normal.y, w_pos.y);
			o.TtoW2 = half4(w_tangent.z, w_binormal.z, w_normal.z, w_pos.z);

			return o;
		}

		// fragment shader
		fixed4 frag_surf(v2f_surf IN) : SV_Target{
			Input surfIN;

			//half3 worldPos = half3(IN.TtoW0.w, IN.TtoW1.w, IN.TtoW2.w);
			surfIN.worldNormal = half3(IN.TtoW0.z, IN.TtoW1.z, IN.TtoW2.z);
			surfIN.uv_texcoord = IN.uv.xy;
			surfIN.uv2_texcoord2 = IN.uv1.xy;
			half3 lightDir = normalize(IN.lightDir);
			surfIN.viewDir = normalize(IN.tangentViewDir);
			surfIN.worldViewDir = normalize(IN.worldViewDir);
			surfIN.TtoW0 = IN.TtoW0.xyz;
			surfIN.TtoW1 = IN.TtoW1.xyz;
			surfIN.TtoW2 = IN.TtoW2.xyz;

			SurfaceOutput o;
			o.Albedo = 0.0;
			o.Emission = 0.0;
			o.Specular = 0.0;
			o.Alpha = 0.0;
			o.Gloss = 0.0;
			fixed3 normalWorldVertex = fixed3(0,0,1);
			o.Normal = fixed3(0,0,1);

			// call surface function
			surf(surfIN, o);
			//UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
			half3 lightColor = half3(1, 1, 1);
			fixed4 c = 0;
			half3 w_normal = normalize(half3(dot(IN.TtoW0.xyz, o.Normal), dot(IN.TtoW1.xyz, o.Normal), dot(IN.TtoW2.xyz, o.Normal)));
			o.Normal = w_normal;

			half3 h = normalize(lightDir + IN.worldViewDir);
			fixed diff = max(0, dot(o.Normal, lightDir));
			half nh = saturate(dot(o.Normal, h));
			half spec = pow(nh, o.Specular*128.0) * o.Gloss;
			c += half4(o.Albedo * lightColor * diff + lightColor * spec, o.Alpha);

			c.rgb += o.Emission;

			return c;
		}
		ENDCG

		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Pass
		{
			Name "FORWARD"
			Lighting Off
			Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma target 3.0
			//#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest

			ENDCG
		}
	}
	Fallback "Diffuse"
}