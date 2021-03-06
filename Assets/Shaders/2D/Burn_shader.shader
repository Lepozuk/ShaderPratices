﻿﻿Shader "LearnToShader/2D/Burn"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

	}

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
            };

            fixed4 _Color;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                

                return OUT;
            }

            sampler2D _MainTex;

            float random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float perlin(float2 uv)
            {
                // 获取 uv 的整数部分       
                float2 i = floor(uv);

                // 获取 uv 的小数部分 
                float2 f = frac(uv);

                // 获取 uv 的相邻坐标 
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));

                // 对 uv 的小数部分进行 smoothstep
                // 因为是小数部分，所以肯定是小于 1 
                // 所以去掉了对 smoothstep 的 step 操作
                // 只保留了 smooth 的过程 
                float2 u = f * f * (3 - 2 * f);

                // 平滑插值, 平滑是柏林的核心
                return lerp(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }


            // fbm
            float fbm(float2 uv)
            {
                float retNoise = 0.0;
                float uvOffset = 2.0;

                for (int i = 0; i < 9; i++)
                {
                    retNoise += perlin(uvOffset * uv) / uvOffset;
                    uvOffset += uvOffset;
                }

                return retNoise;
            }


            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                
                //分型噪音
                float4 fbmNoise = fbm(3.5 * uv);

                // 使用时间的小数部分控制 消融的动画
                float burnFactor = frac(_Time * 10);

                // 只取小数部分
                float fadeoutFactor = frac(burnFactor * 0.9999);

                // 焚烧时会有一段焚烧的距离
                float4 color = smoothstep(fadeoutFactor, fadeoutFactor + 0.1, fbmNoise);

                // 贴图的颜色
                float4 texColor = tex2D(_MainTex, uv);

                // 贴图吸收焚烧颜色
                color = texColor * color;

                // 会根据 burnFactor 改变的颜色
                // 当 burnFactor 为 0 时，与贴图颜色一致
                float3 minColor = color.rgb - burnFactor;


                // 焚烧时候的颜色
                float3 burnColor = float3(24,3,1);
                
                // 会根据 resultColor 的 alpha 改变的颜色
                // 当 resultColor 的 alpha 为 1 时，显示黑色
                // resultColor.a 是根据 fbmNoise 和 fadeoutFactor 得到的
                float3 maxColor = fbmNoise * 10 * burnColor * (1 - color.a);
                
                // 通过 burnFactor 控制焚烧的进度
                // 通过 resultColor 的 透明通道 控制颜色是否可见    
                color.rgb = lerp(minColor, maxColor, burnFactor);
 
                color *= IN.color;
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}
