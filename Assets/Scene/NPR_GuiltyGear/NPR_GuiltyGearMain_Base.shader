Shader "Unlit/NPR_GuiltyGear"
{
	Properties
	{
		Base ("Base Texture", 2D) = "white" {}
		SSS("SSS Texture", 2D) = "white" {}
		ILM("ilm Texture", 2D) = "white" {}

		OutLineZoffset("OutLine Offse", Range(0,1.0)) = 0.25

		BaseLightDir("BaseLightDir", Vector) = (0, 1, 0, 0) //c18
		BaseLightDarkColor("BaseDarkColor", Vector) = (0.427, 0.506, 0.502, 0) // c14
		BaseLightLightColor("BaseLightColor", Vector) = (0.482, 0.471, 0.439, 0) //c17

		PointLightPos("PointLightPos", Vector) = (0, 0, 0, 0) // c16
		PointLightColor("PointLightColor", Vector) = (0, 0, 0, 0)// c15

		HightLightColor("HighLightColor", Vector) = (0.25, 0.25, 0.25, 1)//c19

		_Zoffset("_Zoffset", Range(-1,1)) = 0
		_Gate("_Gate", Range(-1,1)) = 0

		c1("c1", Vector) = (0.100000001, 3, 2, -10)
		c3("c3", Vector) = (0.075000003, -0.5, -0.25, -0.75)
		c4("c4", Vector) = (0.600000024, 0.298999995, 0.587000012, 0.114)
		c6("c6", Vector) = (-0.0000001, 10000, 1, 0)
		c7("c7", Vector) = (1, 0.5, -0.497000009, -0.5)

		c13("c13", Vector) = (0.1, 0, 0, 0.25)
		c14("c14", Vector) = (0.427, 0.506, 0.502, 0) // 平行光暗颜色
		c20("c20", Vector) = (1, 1, 1, 1)
		c21("c21", Vector) = (0, 0, 0, 0)
		c23("c23", Vector) = ( 0, 0.5, 1, 1)
		c24("c24", Vector) = (0.1, 1, 1, 1)
		c25("c25", Vector) = (8, 1, 0, 0)
		c26("c26", Vector) = (2, 0, 4.0199998, 1)

		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		//OutLinePass
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float3 color : COLOR;
				float4 vertex : SV_POSITION;
			};

			sampler2D Base;
			sampler2D SSS;
			sampler2D ILM;

			uniform float OutLineZoffset;
			uniform float _Zoffset;
			uniform float _Gate;

			void Z_BiasMethod(appdata v, inout v2f o)
			{
				float4 viewpos = mul(UNITY_MATRIX_MV, v.vertex);
				//将ViewPos 向靠近摄像机的方向移动
				//Unity 的视口 +Z 方向 在摄像机后方
				viewpos.z += _Zoffset;
				o.vertex = mul(UNITY_MATRIX_P, viewpos);
				o.color = v.color;

			}

			void VertexNormalMethod0(appdata v, inout v2f o)
			{
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(viewnormal);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.xy += offset * _Gate;
				o.color = v.color;

			}

			void VertexNormalMehtod1(appdata v, inout v2f o)
			{
				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);

				//修正矢量 一般是向后方
				viewnormal.z = _Zoffset;

				viewPos += float4(normalize(viewnormal), 0) * _Gate;
				o.vertex = mul(UNITY_MATRIX_P, viewPos);
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

				o.vertex = mul(UNITY_MATRIX_P, viewPos);
				o.color = v.color;

			}

			v2f vert(appdata v)
			{
				v2f o;

				//Z_BiasMethod(v, o);
				//VertexNormalMethod0(v, o);
				//VertexNormalMehtod1(v, o);
				Z_Bias_VertexNormalCombine(v, o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				clip(-1);
				fixed4 col = fixed4(0.0, 0.0, 0.0, 0.0);
				
				return col;
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 color : COLOR;
			};

			struct v2f
			{
				float3 worldnormal : NORMAL;
				float3 color : COLOR;
				float2 uv : TEXCOORD0;
				float4 worldpos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D Base;
			sampler2D SSS;
			sampler2D ILM;

			float3 BaseLightDir;

			//平行光 亮颜色
			float3 BaseLightLightColor;

			//点光源 颜色
			float3 PointLightColor;
			//点光源 位置
			float3 PointLightPos;
			//高光 颜色
			float3 HightLightColor;


			float4 c6;
			float4 c23;
			float4 c7;

			float4 c14;
			float4 c1;
			float4 c3;
			float4 c4;

			float4 c26;
			float4 c24;
			float4 c25;
			float4 c13;
			float4 c20;
			float4 c21;

			//获得修正之后的光源的方向
			float3 GetLightDir(float worldPos)
			{
				return normalize(BaseLightDir);
			}

			//获得点光源比例
			float GetPointLightAlpha()
			{
				return 0;
			}

			//获得点光源的颜色和距离乘反比
			float3 GetPointLight(float3 worldPos)
			{
				float l = length(worldPos - PointLightPos);

				return PointLightColor / l;
			}

			//获得修正之后的光源的颜色 alpha * 点光源颜色 + (1-alpha) * 平行光亮颜色
			float3 GetLBlendightColor(float3 worldPos)
			{
				float pointlightalpha = GetPointLightAlpha();

				return pointlightalpha * GetPointLight(worldPos)
					+ (1 - pointlightalpha) * BaseLightLightColor;
			}

			//获得暗处的SSSColor
			float3 GetSSSColor(float4 sssC)
			{
				float pointlightalpha = GetPointLightAlpha();
				float percent = c14 - c1.x * pointlightalpha * pointlightalpha;

				return sssC * percent;
			}

			
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = v.uv;

				o.worldnormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldpos = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				//return 1;
				float4 base = tex2D(Base, i.uv);
				float4 sss = tex2D(SSS, i.uv);
				float4 ilm = tex2D(ILM, i.uv);


				
				float3 Worldnormal = normalize(i.worldnormal);

				//经过修正之后的光源方向
				float3 LightDir = GetLightDir(i.worldpos);
				//经过修正之后的光源 亮颜色
				float3 LightColor = GetLBlendightColor(i.worldpos);
				//经过修正之后的SSS 暗颜色
				float3 SSSColor = GetSSSColor(sss);

				//法向和光照点乘
				float DotValue1 = dot(LightDir, Worldnormal);
				//法向和世界位置点乘
				float DotValue2 = dot(Worldnormal, -normalize(i.worldpos));


				// 计算标准颜色
				float keyNormal1 = DotValue1 + abs(DotValue2 * c23.x) + c6.z;

				//		      光照贴图G通道 顶点颜色R Debug参数
				float limit = ilm.y * i.color.x * c23.z * keyNormal1 + c7.z;

				//
				float3 Equaloverzero = 2 * LightColor;					// r4 2倍LightColor
				float3 Lessrzero = 2 * SSSColor;						// r6 2倍SSSColor
				
				float BeLight = step(0, limit); // limit >= 0? 1: 0

				//标准光照 选择基本的光照颜色
				float3 NormalColor = BeLight * Equaloverzero + (1 - BeLight) * Lessrzero;


				// 计算边缘光
				float keyNormal2 = (abs(DotValue1 + c1.x) + c6.z)
					* (-DotValue2 + c6.z) * c7.y + c7.w; //( *1/2 -0.5 )

				//					     强度   贴图强度  Debug参数
				float EdageLightStength = c3.x * base.a * c23.w;

				float Equaloverzero1 = EdageLightStength; // keyNormal2 >=0
				float Lessrzero1 = c6.w; //（0）keyNormal2 < 0

				float BeEdageLight = step(0, keyNormal2);
				float EdageStength = BeEdageLight * Equaloverzero1 + (1 - BeEdageLight) * Lessrzero1;

				//标准光照 + 边缘光的结果
				float3 NormalAddEdageColor = NormalColor + EdageStength;


				//计算奇怪的颜色 StengeColor;

				float3 strangeS1 = base.xyz * sss.xyz;
				float3 strangeS2 = 2 * SSSColor;// r6
					strangeS2 *= sss.xyz + c7.y;
					strangeS2 *= c4.x;


				// 计算奇怪光照的百分比
				//c26("c26", Vector) = (2, 0, 4.0199998, 1)
				float3 tempResult = ilm.xxy + c3.zwy;
				
				float templimit = step(-c3.y, ilm.y);
				float ttresult = templimit * c26.x + (1 - templimit) * c26.y;

				tempResult.xy = saturate(tempResult); // 关键值

				ttresult += DotValue1;
				float ttresult1 = i.color.x * (-c26.z) + c26.w;
				ttresult -= ttresult1;

				float templimit1 = step(0, ttresult);
				float lresult = templimit1 * c6.w + (1 - templimit1) * c6.z;
				float templimit2 = step(c24.x, ilm.y);
				float llresult = templimit2 * lresult + (1 - templimit2) * c6.z;

				//奇怪光照的比例
				float beStarnge = saturate(llresult * c24.y);// Debug c24.y

				//混合的光照
				float3 BlendLight = beStarnge * strangeS2 + (1 - beStarnge) * NormalAddEdageColor;


				//高光颜色 和 基础颜色

				float3 HightLihgt = LightColor * 2 * HightLightColor;

				//基础受普通光照影响的颜色
				float3 BaseColor = base * BlendLight;
				//基础受高光 影响的颜色
				float3 HighColor = ilm.x * HightLihgt + BaseColor;


				//高光的分别

				float modify = tempResult.x * -c1.w;
				float modify2 = tempResult.y * c25.x;

				float3 Dir = LightDir * 2 - (normalize(i.worldpos) *  modify);/* sat(ilm.x +c3.z(-0.25))  */
					Dir = normalize(Dir);

				float tempDot = dot(Dir, Worldnormal);

				float tt = c6.z - DotValue2;
				float powvalue = pow(tt, 5);
				float tt2 = powvalue * modify2;
				float powvalue2 = pow(i.color.x, 3);
				float tt3 = powvalue2 * tt2 + abs(tempDot);
				float powvalue3 = pow(tt3, 4);

				float tt4 = c6.z - ilm.z;

				//高光 和 基础颜色的分界
				float BeHighlihgt = step(0, c24.z * i.color.x *  powvalue3 - tt4);
				//最终光照颜色
				float3 LastLightColor = BeHighlihgt * HighColor + (1 - BeHighlihgt) * BaseColor;

				//暗处混合颜色
				float3 DarkColor = c14.xyz;
				float3 DarkBlendColor = c13.w * 2 * DarkColor + (1 - c13.w) * c13.xyz;


				//最终ilm.a 混合颜色
				float3 ilmBlendColor = ilm.a * LastLightColor.xyz + (1 - ilm.a) * DarkBlendColor;

				//Debug 混合颜色
				float debugDot = dot(c4.yzw, ilmBlendColor.xyz);
				float3 DebugBlendColor = c25.y * ilmBlendColor.xyz + (1 - c25.y) * debugDot;

				//修正
				float3 CMColor = c20.xyz * DebugBlendColor + c21;


				return fixed4(ilmBlendColor, 1);
			}
			ENDCG
		}
	}
}
