Shader "Unlit/Procedural_Geometry"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Gate("Gate Value" , Range(0,1)) = 0.1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Cull Back

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

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//计算世界坐标下 视点位置的矢量
				o.viewdir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				o.worldnormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				return o;
			}
			
			//Front 表面正常渲染

			float4 frag(v2f i) : SV_Target
			{
				float4 lastColor = float4(1.0, 1.0, 1.0, 1.0);
				return lastColor;
			}
			ENDCG
		}

		Pass
		{
			Cull Front

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
			float _Gate;

			v2f vert(appdata v)
			{
				v2f o;
				o.worldnormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//计算世界坐标下 视点位置的矢量
				o.viewdir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//将位置沿视口方向进行修正 修正得到的结果进行黑色描边
				o.pos = UnityObjectToClipPos(v.vertex - o.viewdir *_Gate);
				
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 lastColor = float4(0, 0, 0, 0);
				return lastColor;
			}
			ENDCG
		}
	}
}