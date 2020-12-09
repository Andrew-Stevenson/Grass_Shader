Shader "Custom/GrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TipColour("Tip Colour", Color) = (1, 1, 1, 1)
		_StemColour("Stem Colour", Color) = (1, 1, 1, 1)
		_Gradient("Gradient Texture", 2D) = "white" {}
		_Noise("Noise Texture", 2D) = "white" {}
		_WindSpeed("Wind Speed", float) = 1
		_WindDirection("Wind Direction", vector) = (0, 0, 0, 0)
		_WindColour("Wind Colour", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _Gradient;
			sampler2D _Noise;
			float4 _Noise_TexelSize;
            float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			fixed4 _TipColour;
			fixed4 _StemColour;
			float _WindSpeed;
			float2 _WindDirection;
			fixed4 _WindColour;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float sineWave(float T, float a, float phase, float2 dir, float2 pos) {
				return a * sin(2 * 3.14 / T * dot(dir, pos) + phase);
			}

			float getWind(float2 pos, float t) {
				return (sineWave(200, 1.8, _WindSpeed*t, normalize(_WindDirection), pos) +
					sineWave(70, 0.1, 2 * _WindSpeed*t, normalize(_WindDirection - float2(0, 0.4)), pos) +
					sineWave(75, 0.1, 1.5*_WindSpeed*t, normalize(_WindDirection - float2(0.4, 0)), pos))
					/ 3;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

				fixed4 col = fixed4(0, 0, 0, -1);
				float MAXBLADELENGTH = 10;

				float noise = tex2D(_Noise, fixed2(i.uv.x / _MainTex_TexelSize.x / _Noise_TexelSize.z+ _Time[0] * _WindSpeed, 0)).r;

				if (tex2D(_MainTex, i.uv).r > 0) {
					col = tex2D(_Gradient, fixed2(0.5, 0) / 3);
				}

				i.uv.y -= noise * _MainTex_TexelSize.y;

				fixed2 uv = i.uv;

				for (float dist = 0; dist < MAXBLADELENGTH; ++dist) {

					float wind = getWind(float2(uv.x / _MainTex_TexelSize.x, uv.y / _MainTex_TexelSize.y), _Time[1]);

					float blade_length = tex2D(_MainTex, fixed2(uv.x, uv.y)).r * 255;

					if (blade_length > 0) {

						if (wind > 0.5) {
							blade_length -= 1;
						}

						if (abs(dist - blade_length) < 0.00001) {
							col = _TipColour;

							if (wind > 0.5) {
								col = _WindColour;
							}
							else {
		 						col = _TipColour;
							}

						}
						else if (dist < blade_length) {
							col = tex2D(_Gradient, fixed2(dist + 0.5, 0) / 3);
						}
					}

					uv -= fixed2(0, _MainTex_TexelSize.y);

					}

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
