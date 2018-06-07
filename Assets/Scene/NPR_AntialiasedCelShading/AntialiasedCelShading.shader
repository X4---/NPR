Shader "Unlit/AntialiasedCelShading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		
		worldLightDir("LightDir", Vector) = (1,1,1,0)

		c1("c1", Vector) = (0.298999995, 0.587000012, 0.114, 0.000000001)
		c3("c3", Vector) = (2.20000005, 1, 0, 0)
		c4("c4", Vector) = (3, 0.00784313772, -1, 1)

		c8("c8", Vector) = (0.1, 0, 0, 0.25)
		c9("c9", Vector) = (0.427, 0.506, 0.502, 0)
		c10("c10", Vector) = (1, 1, 1, 0)
		c11("c11", Vector) = (0, 0, 0, 0)
		c12("c12", Vector) = (1, 0, 0, 0)

		c229("c229", Vector) = (0.2308682, 0.1154341, 1, 0.7)
		c234("c234", Vector) = (0,1,0,0)
		c235("c235", Vector) = (0.050000007, 0.06750000027, 0.30000012, 0.1000001)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			NAME "AA"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float3 worldLightDir;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldPos = mul( unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float keynormalvalue = dot(worldLightDir, i.worldNormal);


				return 1;
			}
			ENDCG
		}

		UsePass "Unlit/Procedural_Geometry/OUTLINE_PCG"
	}
}
