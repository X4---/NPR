Shader "Unlit/Procedural_Geometry"
{
	Properties
	{
		c1("c1", Vector) =(0.298999995, 0.587000012, 0.114, 0.000000001)
		c3("c3", Vector) =(2.20000005, 1, 0, 0)
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
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			NAME "OUTLINE_PCG"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color: COLOR;
			};

			uniform float4 c1;
			uniform float4 c3;
			uniform float4 c4;
			uniform float4 c8;
			uniform float4 c9;
			uniform float4 c10;
			uniform float4 c11;
			uniform float4 c12;
			uniform float4 c229;
			uniform float4 c234;
			uniform float4 c235;

			//罪恶装备使用的方式 Z-Bias 和VertexNormal 相结合
			//顶线颜色
			//v.color.b 是轮廓线 法向 Normal 修正值
			//v.color.a 轮廓线的粗细 , 0.5 是标准, 1 是最粗, 0是没有

			void Z_Bias_VertexNormalCombine(appdata v, inout v2f o)
			{
				float3 worldnormal = normalize(UnityObjectToWorldNormal(v.normal));
				float4 worldpos = mul(unity_ObjectToWorld, v.vertex);


				float3 ViewDir = UnityWorldSpaceViewDir(worldpos.xyz);
				float l = length(ViewDir);
				
				float3 ViewPart = c235.y * ViewDir;

				float3 WorldPart = c235.x * c229.z * c229.y * v.color.y * v.color.a * l;
					WorldPart += c235.z* c229.z * v.color.a;

					WorldPart *= worldnormal * c235.w; //顶点颜色不对,所以额外进行的一个缩放修正

				float3 offset = c235.w * (ViewPart + WorldPart);

				worldpos.xyz += offset;


				o.pos = UnityWorldToClipPos(worldpos);
				o.color = v.color;

			}
			
			v2f vert(appdata v)
			{
				v2f o;
				//Z_BiasMethod(v, o);
				Z_Bias_VertexNormalCombine(v, o);
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