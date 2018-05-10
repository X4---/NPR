Shader "Unlit/Surface_Angle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LightDir("Light Dir", Vector) = (0 , 1.0, 0, 0)
		_LightPower("Light Power", Vector) = (1.0, 1.0, 1.0, 1.0)
		_Gate("Gate Value" , Range(0,1)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldnormal : NORMAL;
				float3 viewdir : UV;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LightDir;
			float4 _LightPower;
			float _Gate;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldnormal = normalize( mul(v.normal, (float3x3)unity_WorldToObject ));

				//计算世界坐标下 视点位置的矢量
				o.viewdir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				//Used For Debug
				//float4 normalcolor = float4(i.worldnormal, 1.0);

				//计算视点和 法向的点积
				float nl = dot(i.worldnormal ,  i.viewdir);

				//Used For Debug
				//float4 nlcolor = float4(nl, nl, nl, nl);

				nl += 1 - _Gate;
				nl = trunc(nl);

				float4 lastColor = float4(nl, nl, nl, nl);
				return lastColor;
			}
			ENDCG
		}
	}
}