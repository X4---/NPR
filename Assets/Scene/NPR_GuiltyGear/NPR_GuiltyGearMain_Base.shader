Shader "Unlit/NPR_GuiltyGear"
{
	Properties
	{
		Base ("Base Texture", 2D) = "white" {}
		SSS("SSS Texture", 2D) = "white" {}
		ILM("ilm Texture", 2D) = "white" {}

		OutLineZoffset("OutLine Offse", Range(0,1.0)) = 0.25

		BaseLightDir("平行光方向", Vector) = (0, 1, 0, 0) //c18
		BaseLightDarkColor("平行光 光颜色", Vector) = (0.427, 0.506, 0.502, 0) // c14
		BaseLightLightColor("平行光 阴颜色", Vector) = (0.482, 0.471, 0.439, 0) //c17

		PointLightPos("点光位置", Vector) = (0, 0, 0, 0) // c16
		PointLightColor("点光颜色", Vector) = (0, 0, 0, 0)// c15

		LightOrDarkNormalScale("明暗-法向缩放", Range(0,2)) = 1 // c23.z			//Default 1
		LightOrDarkWolrdPosScale("明暗偏移值缩放", Range(-1,1)) = 0 //c23.x			//Default 0

		EdageLightPower("边缘光强度", Range(0,2)) = 1 //c23.w						//Default 1

		ShadowLimit("ILM影的阈值", Range(0,1)) = 0.1 //c24.x
		ShadowColorBlend("SSS影颜色混合值", Range(0,1)) = 1 // c24.y

		HightLightColor("高光颜色", Vector) = (0.25, 0.25, 0.25, 1)//c19
		HightLightScale("高光倾向", Range(0,2)) = 1 // c24.z
		HighLightSpecial("高光特殊", float) = 8 // c25.x

		GrayPower("灰度点乘值", Vector) = (0.298999995, 0.587000012, 0.114, 1) // 灰度强度值 点乘获得目标颜色的灰度 c4.yzw
		GrayOrColor("灰度混合值", Range(0,1)) = 1  // c25.y

		//c1("c1", Vector) = (0.100000001, 3, 2, -10)
		//c3("c3", Vector) = (0.075000003, -0.5, -0.25, -0.75)
		//c4("c4", Vector) = (0.600000024, 0.298999995, 0.587000012, 0.114)
		//c6("c6", Vector) = (-0.0000001, 10000, 1, 0)
		//c7("c7", Vector) = (1, 0.5, -0.497000009, -0.5)

		DarkBlendColorS("ILMA 影混合颜色", Vector) = (0.1, 0, 0, 0.25)
		//BaseLightDarkColor("BaseLightDarkColor", Vector) = (0.427, 0.506, 0.502, 0) // 平行光暗颜色 c14
		ColorScale("ColorScale", Vector) = (1, 1, 1, 1) // c20
		ColorOffset("ColorOffset", Vector) = (0, 0, 0, 0) // c21

		//c23("c23", Vector) = ( 0, 0.5, 1, 1)
		//c24("c24", Vector) = (0.1, 1, 1, 1)
		//c25("c25", Vector) = (8, 1, 0, 0)

		//c26("c26", Vector) = (2, 0, 4.0199998, 1)	// 常量
		
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
			float HightLightScale;
			float HighLightSpecial;

			uniform float DebugFlow;
			
			//float4 c23;
			

			float4 BaseLightDarkColor;
			static float4 c1 = float4(0.100000001, 3, 2, -10);
			static float4 c3 = float4(0.075000003, -0.5, -0.25, -0.75);
			static float4 c4 = float4(0.600000024, 0.298999995, 0.587000012, 0.114);
			static float4 c6 = float4(-0.0000001, 10000, 1, 0);
			static float4 c7 = float4(1, 0.5, -0.497000009, -0.5);
			static float4 c26 = float4(2, 0, 4.0199998, 1);

			float4 GrayPower;
			float GrayOrColor;

			float LightOrDarkNormalScale;
			float LightOrDarkWolrdPosScale;

			float ShadowLimit;
			float ShadowColorBlend;

			float EdageLightPower;

			//float4 c26;
			//float4 c24;
			//float4 c25;
			float4 DarkBlendColorS;
			float4 ColorScale;
			float4 ColorOffset;

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
				float percent = BaseLightDarkColor - c1.x * pointlightalpha * pointlightalpha;

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

				//float DotValue2 = dot(Worldnormal, -normalize(i.worldpos));
				float DotValue2 = dot(Worldnormal, normalize(_WorldSpaceCameraPos.xyz - i.worldpos));


				// 计算标准颜色
				float keyNormal1 = DotValue1 + abs(DotValue2 * LightOrDarkWolrdPosScale /*c23.x*/) + c6.z;

				//		      光照贴图G通道 顶点颜色R Debug参数
				float limit = ilm.y * i.color.x * LightOrDarkNormalScale/*c23.z*/ * keyNormal1 + c7.z;

				float3 Equaloverzero = 2 * LightColor;					// r4 2倍LightColor
				float3 Lessrzero = 2 * SSSColor;						// r6 2倍SSSColor
				
				float BeLight = step(0, limit); // limit >= 0? 1: 0

				//标准光照 选择基本的光照颜色
				float3 NormalColor = BeLight * Equaloverzero + (1 - BeLight) * Lessrzero;

			
	
				// 计算边缘光
				float keyNormal2 = (abs(DotValue1 + c1.x) + c6.z)
					* (-DotValue2 + c6.z) * c7.y + c7.w; //( *1/2 -0.5 )

				//					     强度   贴图强度  Debug参数
				float EdageLightStength = c3.x * base.a * EdageLightPower;//c23.w;

				float Equaloverzero1 = EdageLightStength; // keyNormal2 >=0
				float Lessrzero1 = c6.w; //（0）keyNormal2 < 0

				float BeEdageLight = step(0, keyNormal2);
				float EdageStength = BeEdageLight * Equaloverzero1 + (1 - BeEdageLight) * Lessrzero1;

				//标准光照 + 边缘光的结果
				float3 NormalAddEdageColor = NormalColor + EdageStength;
				//return BeEdageLight;
				//return fixed4(NormalAddEdageColor, 1);


				//计算奇怪的颜色 影的颜色;
				float3 strangeS1 = base.xyz * sss.xyz;
				float3 strangeS2 = 2 * SSSColor;// r6
					strangeS2 *= sss.xyz + c7.y;
					strangeS2 *= c4.x;


				// 计算奇怪光照的百分比
				//c26("c26", Vector) = (2, 0, 4.0199998, 1)
				//c3("c3", Vector) = (0.075000003, -0.5, -0.25, -0.75)
				float3 tempResult = ilm.xxy + c3.zwy;

				//tempResult.x = ilm.x - 0.25   //高光强度 -0.25
				//tempResult.y = ilm.x - 0.75   //高光强度 -0.75
				//tempResult.z = ilm.y - 0.5    //明暗倾向 - 0.5
				
				float templimit = step(-c3.y, ilm.y); // ilm.y >= 0.5 ? 明暗的倾向 >= 0.5 ？ 2 ： 0
				float ttresult = templimit * c26.x + (1 - templimit) * c26.y;

				tempResult.xy = saturate(tempResult); // 关键值

				ttresult += DotValue1;
				float ttresult1 = i.color.x * (-c26.z) + c26.w;			//i.color.x 阴(明）的权重参数， 1是标准， 0 是恒定的阴
				ttresult -= ttresult1;

				//DotValue1 + c26.z * i.color.x - c26.w + （2 : 0）;
				//ilm.y >=0.5 ? 倾向于明 则这个值恒定大于》0
				//ilm.y < 0.5 ? 倾向于阴 则  DotValue1  >= 1 - 4.2 * i.color.x // 如果法向乘积 大于 1 - 4.2倍 顶点明的倾向 

				float templimit1 = step(0, ttresult);
				float lresult = templimit1 * c6.w + (1 - templimit1) * c6.z; // 0 : 1
				float templimit2 = step(ShadowLimit, ilm.y);

				// ilm.y > = 0.5
				// tempresult = 0;

				// ilm.y < 0.5
				// tempresult = 0  可能为1 : DotValue1  >= 1 - 4.2 * i.color.x

				// 假设 c24.x 通常情况下 小于 0.5

				// ilm.y >= c24.x
				// 结果就是  DotValue1 < 1-4.2 * i.color.x   = > 1 结果  启用 Starnge2 阴
				// ilm.y < c24.x
				// 结果就是 c6.z => 1 结果 也是启用 Strange2 阴

				// 简单的说
				// ilm.y < c24.x 的话 这个地方 就直接采用  阴颜色
				// ilm.y >= c24.x 的地方 采用夹断值
						//1. ilm.y >= 0.5 光颜色
						//2. ilm.y < 0.5 通过  Dotvalue1 >= 1-4.2 * i.color.x  来采用光

				float llresult = templimit2 * lresult + (1 - templimit2) * c6.z;

				//阴影光照的比例
				float beStrange = saturate(llresult * ShadowColorBlend);// Debug c24.y
				//影的颜色 + (1-比例) 光阴混合的光照
				float3 BlendLight = beStrange * strangeS2 + (1 - beStrange) * NormalAddEdageColor;

				//return beStrange;
				//return fixed4(beStrange * strangeS2, 1);
				//return fixed4(BlendLight, 1);


				//高光颜色 和 基础颜色
				float3 HightLihgt = LightColor * 2 * HightLightColor;
				//基础受普通光照影响的颜色
				float3 BaseColor = base * BlendLight;
				//基础受高光 影响的颜色
				float3 HighColor = ilm.x * HightLihgt + BaseColor;

				//tempResult.x = ilm.x - 0.25   //高光强度 -0.25
				//tempResult.y = ilm.x - 0.75   //高光强度 -0.75
				//tempResult.z = ilm.y - 0.5    //明暗倾向 - 0.5
				//tempResult.xy = saturate(tempResult); // 关键值

				//高光的分别
				float modify = tempResult.x * -c1.w;
				float modify2 = tempResult.y * HighLightSpecial;

				float3 Dir = LightDir * 2 - (DotValue2 *  modify);/* sat(ilm.x +c3.z(-0.25))  */

				// Dir = LightDir - DotValue2 * modify/2;
				// Dir = Lightdir * 2 -  dot(Worldnormal, CameraPos - worldPos) * modify

				Dir = normalize(Dir);

				float tempDot = dot(Dir, Worldnormal);

				// tempDot = dot(Dir, worldnormal) / |Dir|
				// 2 * dot(LightDir, worldnormal) -  dot( (modify * ( dot(Worldnormal, CameraPos) - dot(Worldnormal, worldPos) ) , worldnormal)
				// 2 * DotValue1 - dot((..) I, worldnormal)


				float tt = c6.z - DotValue2;
				float powvalue = pow(tt, 5);
				float tt2 = powvalue * modify2;
				float powvalue2 = pow(i.color.x, 3);
				float tt3 = powvalue2 * tt2 + abs(tempDot);
				float powvalue3 = pow(tt3, 4);

				float tt4 = c6.z - ilm.z;
				
				//
				float HightLightLimit = HightLightScale * i.color.x *  powvalue3 - tt4;

				//return HightLightLimit + c6.z;

				//高光 和 基础颜色的分界
				float BeHighlihgt = step(0, HightLightScale * i.color.x *  powvalue3 - tt4);
				//最终光照颜色
				float3 LastLightColor = BeHighlihgt * HighColor + (1 - BeHighlihgt) * BaseColor;

				//return BeHighlihgt;
				
				//暗处混合颜色
				float3 DarkColor = BaseLightDarkColor.xyz;
				float3 DarkBlendColor = DarkBlendColorS.w * 2 * DarkColor + (1 - DarkBlendColorS.w) * DarkBlendColorS.xyz;

				//最终ilm.a 混合颜色
				float3 ilmBlendColor = ilm.a * LastLightColor.xyz + (1 - ilm.a) * DarkBlendColor;

				//获得对应混合颜色的灰度
				float debugDot = dot(GrayPower.xyz, ilmBlendColor.xyz);
				//获得灰度混合颜色
				float3 DebugGrayBlendColor = GrayOrColor * ilmBlendColor.xyz + (1 - GrayOrColor) * debugDot;

				//修正
				float3 CMColor = ColorScale.xyz * DebugGrayBlendColor + ColorOffset;

				return fixed4(CMColor, 1);
			}
			ENDCG
		}
	}
}
