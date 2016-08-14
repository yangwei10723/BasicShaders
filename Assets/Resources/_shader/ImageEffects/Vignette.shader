Shader "Hidden/YW/Vignette"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_VignetteInstensity ("vignetteIntensity", Range(0, 10)) = 1
		[Toggle(SMOOTH)] _Smooth ("Smooth", int) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma multi_compile __ SMOOTH

			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _VignetteInstensity;

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv =( i.uv - 0.5) * 2;	// 将uv坐标转换到[-1, 1]区间，原点是屏幕中间
				//float uvDot = sqrt(dot(uv, uv));		// 计算转换后的uv坐标到屏幕中间的距离
				float uvDot = dot(uv, uv);		// 因为是半径为1的圆，小于1的数乘以小于1的数还是小于1，所以使用距离的平方也能近似的得到结果
				uvDot = uvDot * _VignetteInstensity; // 乘以强度，强度越大黑色区域越大
				#ifndef SMOOTH
				uvDot = step(1, uvDot);		
				#endif
				float mask = saturate(1 - uvDot); 

				fixed4 col = tex2D(_MainTex, i.uv);
				return col * mask;
			}
			ENDCG
		}
	}
}
