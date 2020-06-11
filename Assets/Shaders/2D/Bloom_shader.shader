﻿Shader "LearnToShader/2D/Bloom"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Glow("Glow", range(0,1)) = 0.25
		_Amount("Amount", range(1,10)) = 1
		_ScreenResolution("ScreenSize", Vector) = (512,512,0,0)
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
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord  : TEXCOORD0;
            };

            sampler2D _MainTex;
            
            float _Glow;
            float _Amount;
            float4 _ScreenResolution;
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                return OUT;
            }
            
             
            
            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                float4 color = tex2D(_MainTex, uv);
                


                float stepU = (1.0 / _ScreenResolution.x) * _Amount;
                float stepV = (1.0 / _ScreenResolution.y) * _Amount;

                float3x3 glowKernel = float3x3(1,2,1, 2,4,2, 1,2,1);
                                             
                float4 glow = 0;
                
                // 卷积操作
                for(int u = 0; u < 3; u++) 
                {
                    for(int v = 0; v < 3; v++) 
                    {
                        glow += glowKernel[u][v] * tex2D(_MainTex, uv.xy + float2( float(u-1) * stepU, float(v-1) * stepV ));
                    }
                }

                // result 是 16(1x4+2x4+4) 倍的像素值
                // 除以 8 会比原来的颜色“亮”
                glow /= 8;

                // 插值计算
                color.rgb = lerp (color.rgb, glow.rgb, _Glow).rgb;

                return color;
            }
            ENDCG
        }
    }
}
