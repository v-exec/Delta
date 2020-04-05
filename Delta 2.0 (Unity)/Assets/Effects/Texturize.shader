Shader "Texturize" {
	Properties {
		//general
		_MainTex ("", 2D) = "black" {}
		_Ghost ("", 2D) = "black" {}
		_Brightness ("", Range(0.0, 2.0)) = 1.0
		_Threshold ("", Range(0.0, 0.9)) = 0.0
		_SmearAmount ("", Range(0.0, 0.5)) = 0.0
		_Resolution ("", Range(1, 20)) = 5
		_Mode ("", Range(0, 4)) = 0
		
		//point
		_PointSize ("", Range(0.01, 5.0)) = 0.01

		//ascii
		_ASCIISample ("", 2D) = "black" {}
		_ASCIISampleWidth ("", Int) = 180
		_ASCIIDimensions ("", Int) = 20
		_ASCIICount ("", Int) = 9
	}
	
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"

			//general
			float4 _MainTex_TexelSize;

			sampler2D _MainTex;
			sampler2D _Ghost;
			float _Brightness;
			float _Threshold;
			float _SmearAmount;
			int _Resolution;
			int _Mode;

			//point
			float _PointSize;

			//ascii
			sampler2D _ASCIISample;
			int _ASCIISampleWidth;
			int _ASCIIDimensions;
			int _ASCIICount;

			float thresh(fixed3 color) {
				float c = dot(color, fixed3(_Brightness, _Brightness, _Brightness));
				if (c > _Threshold) return c;
				else return 0.0;
			}

			fixed4 ditherBayer2(fixed2 position, float brightness) {
				int x = fmod(position.x, 4);
				int y = fmod(position.y, 4);

				float4x4 lim = {
				0.2, 0.6, 0.2, 0.7,
				0.9, 0.3, 0.9, 0.4,
				0.2, 0.8, 0.2, 0.6,
				1.0, 0.5, 0.9, 0.4
				};

				if (brightness < lim[y][x]) return fixed4(0.0, 0.0, 0.0, 0.0);
				
				return fixed4(1.0, 1.0, 1.0, 1.0);
			}

			fixed3 ditherBayer(fixed2 position, fixed3 col) {
				return ditherBayer2(position, thresh(col));
			}

			fixed4 asciiChase2(fixed2 position, float brightness) {
				int x = fmod(position.x, _ASCIIDimensions);
				int y = fmod(position.y, _ASCIIDimensions);

				if (brightness < 0.1) return fixed4(0.0, 0.0, 0.0, 1.0);

				int treatedBrightness = (int)floor((brightness - 0.1) * 10);
				treatedBrightness = (int)clamp(treatedBrightness, 0, _ASCIICount - 1);
				int offset = treatedBrightness * _ASCIIDimensions;

				float offsetX = (x + (float)offset) / (float)_ASCIISampleWidth;
				float offsetY = y / (float)_ASCIIDimensions;

				return tex2D(_ASCIISample, fixed2(offsetX, offsetY));
			}

			fixed3 asciiChase(fixed2 position, fixed3 col) {
				return asciiChase2(position, thresh(col));
			}

			fixed4 frag (v2f_img i) : SV_TARGET {
				float luma = thresh(tex2D(_Ghost, i.uv));

				int sampleX = floor(i.pos.x / _Resolution) * _Resolution;
				int sampleY = floor(i.pos.y / _Resolution) * _Resolution;
				float lumi = thresh(tex2D(_Ghost, fixed2(sampleX / _MainTex_TexelSize.z, 1 - (sampleY / _MainTex_TexelSize.w))));

				if (_Mode == 0) {

					//point
					if ((int)(i.uv.x * _MainTex_TexelSize.z) % _Resolution < _PointSize && (int)(i.uv.y * _MainTex_TexelSize.w) % _Resolution < _PointSize) return fixed4(luma, luma, luma, 1.0);
					return fixed4(0.0, 0.0, 0.0, 1.0);

				} else if (_Mode == 1) {

					//ascii
					//sample pixel at _ASCIIDimensions divisions to make sure all pixels in block are drawing the same letter
					sampleX = floor(i.pos.x / _ASCIIDimensions) * _ASCIIDimensions;
					sampleY = floor(i.pos.y / _ASCIIDimensions) * _ASCIIDimensions;

					lumi = thresh(tex2D(_Ghost, fixed2(sampleX / _MainTex_TexelSize.z, 1 - (sampleY / _MainTex_TexelSize.w))));
					return fixed4(asciiChase(i.pos.xy, fixed3(lumi, lumi, lumi)), 1.0);

				} else if (_Mode == 2) {

					//dither
					int offsetX = fmod(floor(i.pos.x / _Resolution), 4);
					int offsetY = fmod(floor(i.pos.y / _Resolution), 4);

					return fixed4(ditherBayer(fixed2(offsetX, offsetY), fixed3(lumi, lumi, lumi)), 1.0);

				} else if (_Mode == 3) {

					//pixelate
					return fixed4(fixed3(lumi, lumi, lumi), 1.0);

				} else {

					//blowout
					if (lumi > 0.5) return fixed4(1.0, 1.0, 1.0, 1.0);
					return fixed4(0.0, 0.0, 0.0, 1.0);
				}
			}
			ENDCG
		}
	}
}