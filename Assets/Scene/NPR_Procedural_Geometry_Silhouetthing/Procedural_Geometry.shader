Shader "Unlit/Procedural_Geometry"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Gate("Gate Value" , Range(0,1)) = 0.1
		_Zoffset("Zoff", float) = -1.0
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
			uniform float4 _MainTex_ST;
			uniform float4 _LightDir;
			uniform float4 _LightPower;
			uniform float _Gate;
			uniform float _Zoffset;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

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
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color: COLOR;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Gate;
			uniform float _Zoffset;

			void Z_BiasMethod(appdata v, inout v2f o)
			{
				float4 viewpos = mul(UNITY_MATRIX_MV, v.vertex);
				//将ViewPos 向靠近摄像机的方向移动
				//Unity 的视口 +Z 方向 在摄像机后方
				viewpos.z += _Zoffset;
				o.pos = mul(UNITY_MATRIX_P, viewpos);
				o.color = v.color;

			}

			void VertexNormalMethod0(appdata v, inout v2f o)
			{
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(viewnormal);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.xy += offset * _Gate;
				o.color = v.color;

			}

			void VertexNormalMehtod1(appdata v, inout v2f o)
			{
				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				
				//修正矢量 一般是向后方
				viewnormal.z = _Zoffset;

				viewPos += float4(normalize(viewnormal),0) * _Gate;
				o.pos = mul(UNITY_MATRIX_P, viewPos);
				o.color = v.color;

			}

			//罪恶装备使用的方式 Z-Bias 和VertexNormal 相结合
			//顶线颜色
			//v.color.b 是轮廓线 法向 Normal 修正值
			//v.color.a 轮廓线的粗细 , 0.5 是标准, 1 是最粗, 0是没有

			void Z_Bias_VertexNormalCombine(appdata v, inout v2f o)
			{
				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);

				//
				viewnormal.z = -v.color.b;
				viewPos += float4(normalize(viewnormal), 0) * _Gate * v.color.a;

				o.pos = mul(UNITY_MATRIX_P, viewPos);
				o.color = v.color;

			}
			
			v2f vert(appdata v)
			{
				v2f o;
				//Z_BiasMethod(v, o);
				VertexNormalMethod0(v, o);
				VertexNormalMehtod1(v, o);
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