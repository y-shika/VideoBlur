Shader "Custom/Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Spread ("Standard Deviation (Spread)", Float) = 0
        _GridSize ("Grid Size", Integer) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        HLSLINCLUDE
        #include "UnityCG.cginc"
        #define E 2.71828f
        
        sampler2D _MainTex;
        
        cbuffer UnityPerMaterial
        {
            float4 _MainTex_TexelSize;
            uint _GridSize;
            float _Spread;
        }
        
        float gaussian(int x)
        {
            float sigmaSqu = _Spread * _Spread;
            return (1 / sqrt(UNITY_TWO_PI * sigmaSqu)) * pow(E, -(x * x) / (2 * sigmaSqu));
        }
        
        struct appdata
        {
            float4 positionOS : POSITION; // Object Space
            float2 uv : TEXCOORD0;
        };
        
        struct v2f
        {
            float4 positionCS : SV_Position; // Clip Space
            float2 uv : TEXCOORD0;
        };

        v2f vert(appdata v)
        {
            v2f o;
            o.positionCS = UnityObjectToClipPos(v.positionOS);
            o.uv = v.uv;
            return o;
        }
        ENDHLSL
        
        Pass
        {
            Name "Horizontal"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag_horizontal

            float4 frag_horizontal(v2f i) : SV_Target
            {
                float3 col = float3(0, 0, 0);
                float gridSum = 0;

                int upper = ((_GridSize - 1) / 2);
                int lower = -upper;

                 for (int x = lower; x <= upper; x++)
                 {
                     float gauss = gaussian(x);
                     gridSum += gauss;
                     float2 uv = i.uv + float2(_MainTex_TexelSize.x * x, 0);
                     col += gauss * tex2D(_MainTex, uv).xyz;
                 }

                col /= gridSum;
                return float4(col, 1);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Vertical"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag_vertival

            float4 frag_vertival(v2f i) : SV_Target
            {
                float3 col = float3(0, 0, 0);
                float gridSum = 0;

                int upper = ((_GridSize - 1) / 2);
                int lower = -upper;

                for (int y = lower; y <= upper; y++)
                {
                    float gauss = gaussian(y);
                    gridSum += gauss;
                    float2 uv = i.uv + float2(0, _MainTex_TexelSize.y * y);
                    col += gauss * tex2D(_MainTex, uv).xyz;
                }

                col /= gridSum;
                return float4(col, 1);
            }
            ENDHLSL
        }
    }
}
