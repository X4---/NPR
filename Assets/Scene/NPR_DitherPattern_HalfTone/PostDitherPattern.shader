Shader "Post/PostDitherPattern"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Dither	("Dither", 2D) = "white"{}
		_DitherSize("DitherSize", float) = 4
		_GateValue("GateValue", Range(0,1)) = 0.5
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _Dither;
			float _DitherSize;
			float _GateValue;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 a = _ScreenParams;
				
				fixed2 countxy = _ScreenParams.xy / _DitherSize;
				fixed4 dithercol = tex2D(_Dither, i.uv * countxy);
				// just invert the 
				fixed graypower = col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
				fixed belight = step(dithercol.r, graypower);

				return belight;
				return col * belight;
			}
			ENDCG
		}
	}
}
