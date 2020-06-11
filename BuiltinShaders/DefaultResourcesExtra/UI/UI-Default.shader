// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
Shader "UI/Default" //Shader的名字
{
    Properties //定义当前Shader可以接收的参数
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }//贴图信息
        _Color ("Tint", Color) = (1, 1, 1, 1) //偏色信息

        _StencilComp ("Stencil Comparison", Float) = 8 //模板测试的比较方式
        _Stencil ("Stencil ID", Float) = 0 //模板的ID
        _StencilOp ("Stencil Operation", Float) = 0 //模板测试结果判断
        _StencilWriteMask ("Stencil Write Mask", Float) = 255 //是否写入模板
        _StencilReadMask ("Stencil Read Mask", Float) = 255 //是否读取模板

        _ColorMask ("Color Mask", Float) = 15 //遮罩通道

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0 //遮罩开关
    }

    SubShader
    {
        /// SubShader的定义
        /// "Queue" 定义渲染组,
        /// "IgnoreProjector" 忽略投影信息,
        /// "RenderType" 渲染类型是透明,
        /// "PreviewType" 在编辑器中以平面的形式预览,
        /// "CanUseSpriteAtlas" 可以使用图集,
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
        
        /// 模板设置
        /// "Ref" 模板ID
        /// "Comp" 模板比较方式
        /// "Pass" 当前Subshader以何种方式通过判断
        /// "ReadMask" 读模板
        /// "WriteMask" 写模板
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off    //是否要进行顶点裁切
        Lighting Off //是否要使用光
        ZWrite Off //是否要写入深度
        ZTest [unity_GUIZTestMode]//是否进行深度测试
        Blend SrcAlpha OneMinusSrcAlpha//叠加模式
        ColorMask [_ColorMask]//通道遮罩,主输出指定通道的颜色

        Pass
        {
            /// 当前Pass的名字是DEFAULT
            Name "Default"

            /// CG代码开始 [ HLSLPROGRAM, GLSLPROGRAM ]
            CGPROGRAM
            
            /// 定义处理顶点信息的函数名
            #pragma vertex vert

            /// 定义处理片元信息的函数名
            #pragma fragment frag

            /// 声明当前的函数兼容sm2.0及以上版本
            /// target相关
            /// SEE: https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
            #pragma target 2.0

            /// 引用UnityCG的宏定义
            #include "UnityCG.cginc"

            /// 引用UnityUI的宏定义
            #include "UnityUI.cginc"

            /// 定义UNITY_UI_CLIP_RECT变体参数
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            /// 定义UNITY_UI_ALPHACLIP变体参数
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            /// 变体相关
            /// SEE: https://docs.unity3d.com/Manual/SL-MultipleProgramVariants.html

            /// 定义从APP阶段可以获得的数据结构
            /// appdata阶段可以在birp中可以使用的参数 SEE: UnityCG.cginc
            struct appdata_t
            {
                float4 vertex: POSITION;    //对象空间的顶点坐标
                float4 color: COLOR;        //顶点色
                float2 texcoord: TEXCOORD0; //UV0
                UNITY_VERTEX_INPUT_INSTANCE_ID //UNITY_VERTEX_INPUT_INSTANCE_ID为顶点实例化一个ID
            };

            /// 定义顶点到片元的数据结构
            struct v2f
            {
                /// 投影空间的顶点坐标
                float4 vertex: SV_POSITION;

                /// 顶点色
                fixed4 color: COLOR;

                /// UV0的插值信息
                float2 texcoord: TEXCOORD0;

                /// 对象空间的顶点
                float4 worldPosition: TEXCOORD1;

                /// UNITY_VERTEX_OUTPUT_STEREO来声明该顶点是否位于视线域中，来判断这个顶点是否输出到片段着色器
                UNITY_VERTEX_OUTPUT_STEREO
            };

            //// UNITY_VERTEX_INPUT_INSTANCE_ID 和 UNITY_VERTEX_OUTPUT_STEREO。
            //// 两个宏定义位于UnityInstancing.cginc中，GPU Instancing所需


            /// _MainTex的采样器(贴图)
            sampler2D _MainTex;
            /// 声明_MainTex是一张采样图，也就是会进行UV运算。  如果没有这句话，是不能进行TRANSFORM_TEX的运算的。
            float4 _MainTex_ST;

            /// 颜色偏向信息
            fixed4 _Color;

            /// 贴图是 Alpha8 格式的时候, 此值为(1,1,1,0), 非Alpha8格式的时候为 (0,0,0,0)
            /// TextureFormat.Alpha8: Alpha-only texture format
            fixed4 _TextureSampleAdd;

            /// 供Mask使用的遮罩裁切区域
            float4 _ClipRect;


            
            v2f vert(appdata_t v)
            {
                /// 定义v2f的结构体
                v2f OUT;

                /// 初始化gpuinstancing的顶点信息
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                /// 保留对象空间的坐标
                OUT.worldPosition = v.vertex;

                /// 将对象空间的顶点信息转换到投影空间
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                /// 转换到正确的UV坐标(应用贴图的tile信息)
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                /// 颜色预先乘上色偏
                OUT.color = v.color * _Color;
                
                return OUT;
            }

            fixed4 frag(v2f IN): SV_Target
            {
                /// 获取到当前像素的颜色信息
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                /// 2D遮罩的裁切
                #ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                /// 裁切掉alpha通道小于0.001值的像素
                #ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
                #endif

                return color;
            }
            /// CG代码结束 [ ENDHLSL, ENDGLSL ]
            ENDCG
            
        }
    }
}
