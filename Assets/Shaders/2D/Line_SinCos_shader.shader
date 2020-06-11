﻿Shader "LearnToShader/2D/Line_SinCos"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("LineColor", Color) = (1,1,1,1)
		_Width("Width",Range(0,1)) = 0
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
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _Color;
            float _Width;


            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;

                return OUT;
            }

            float IsInLine(float x,float y)
            {
                return smoothstep(x - _Width * 0.5, x, y) - smoothstep(x, x + _Width * 0.5, y);
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;

                float radius = lerp(0, 3.1415926, uv.x);
                
                float4 color = tex2D(_MainTex,uv) * IN.color;
                
                color.rgb = lerp(color.rgb, _Color.rgb, IsInLine(sin(radius), uv.y)) + 
                            lerp(color.rgb, _Color.rgb, IsInLine((cos(radius) + 1) * 0.5, uv.y));
                color.rgb *= 0.5 * color.a;
                
                return color;
            }
        ENDCG
        }
    }
}
