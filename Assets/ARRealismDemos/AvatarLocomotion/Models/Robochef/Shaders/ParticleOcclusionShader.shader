//-----------------------------------------------------------------------
// <copyright file="ParticleOcclusionShader.shader" company="Google LLC">
//
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// </copyright>
//-----------------------------------------------------------------------
Shader "Custom/Particle Occlusion Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _CurrentDepthTexture("Depth Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 200

        Pass
        {
            ZWrite On
            ColorMask 0
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:blend

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Assets/ARRealismDemos/Common/Shaders/ARCoreDepth.cginc"

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
            float3 worldPos;
        };

        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

#if UNITY_VERSION >= 201701
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
#endif

        // Discard the current pixel if it is hidden behind the derived depth data.
        void DoDepthClipping(Input IN)
        {
            // Screen pixel coordinate, to lookup depth texture value.
            float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            float2 uv = ArCoreDepth_GetUv(screenUV);

            // Unpack depth texture distance.
            float realDepth = ArCoreDepth_GetMeters(uv);

            // Find distance to the 3D point along the principal axis.
            float virtualDepth = -UnityWorldToViewPos(IN.worldPos).z;

            // Discard if object is obscured behind the depth texture.
            clip(realDepth - virtualDepth);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            //DoDepthClipping(IN);

            // Screen pixel coordinate, to lookup depth texture value.
            float2 screenUV = IN.screenPos.xy / (IN.screenPos.w + 0.0000001);
            float2 uv = ArCoreDepth_GetUv(screenUV);

            // Default surface shader behavior.
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo.rgb = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a * ArCoreDepth_GetVisibility(uv, UnityWorldToViewPos(IN.worldPos));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
