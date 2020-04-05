Shader "Ghost" {
	Properties {
		_MainTex ("", 2D) = "black" {}
		_SmearAmount ("", Range(0.0, 1.0)) = 0.0
		_Past ("", 2D) = "black" {}
	}
	
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _SmearAmount;
			sampler2D _Past;

			fixed4 frag (v2f_img i) : SV_TARGET {
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed4 previousColor = tex2D(_Past, i.uv);

				//less of original color
				color /= (10 + (_SmearAmount * 10));

				//more of accumulated color
				previousColor /= 2.02 - _SmearAmount;

				return color + previousColor;
			}
			ENDCG
		}
	}
}