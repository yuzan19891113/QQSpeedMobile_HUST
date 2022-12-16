

Shader "Hidden/QSMBlit"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" { }
	}
	SubShader
	{
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0

			
			
			uniform sampler2D _MainTex;
			
			struct appdata_t
			{
				float4 vertex: POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 texcoord: TEXCOORD0;
				float4 vertex: SV_POSITION;
				float4 color: COLOR;
			};
			
			
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
				
				return OUT;
			}
			
	
			half4 _MainTex_ST;
			half4 frag(v2f i): COLOR
			{
				float2 uvst = UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST);
                float2 uv = uvst.xy;
				half4 color = tex2D(_MainTex, uv);
				
				half3 linearColor = max(color.rgb, half3(0.0001h, 0.0001h, 0.0001h));
				return half4(sqrt(linearColor), color.a);
			}
			
			ENDCG
			
		}
	}
}