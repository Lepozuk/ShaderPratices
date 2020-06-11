﻿Shader "LearnToShader/2D/4Gradient"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		
		_Color("Tint", Color) = (1,1,1,1)

        // 四个点的颜色设置
        _LeftTopColor("LeftTopColor",Color) = (1,1,1,1)
        _LeftBottomColor("LeftBottomColor",Color) = (1,1,1,1)
        _RightTopColor("RightTopColor",Color) = (1,1,1,1)
        _RightBottomColor("RightBottomColor",Color) = (1,1,1,1)
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

            sampler2D _MainTex;
            
            float4 _LeftTopColor;
            float4 _LeftBottomColor;
            float4 _RightTopColor;
            float4 _RightBottomColor;
            fixed4 _Color;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                
                fixed4 topLeft2RightColor = lerp(_LeftTopColor,_RightTopColor,uv.x);
                fixed4 bottomLeft2RightColor = lerp(_LeftBottomColor,_RightBottomColor,uv.x);
                fixed4 bottom2TopColor = lerp(bottomLeft2RightColor,topLeft2RightColor,uv.y);

                fixed4 color = tex2D(_MainTex, uv) * bottom2TopColor;
                                
                color.rgb *= color.a;
                
                return color;
            }
            ENDCG
        }
    }
}
