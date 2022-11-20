// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef TT_UNITY_STANDARD_CORE_INCLUDED
    #define TT_UNITY_STANDARD_CORE_INCLUDED

    #include "UnityCG.cginc"
    #include "UnityShaderVariables.cginc"
    #include "UnityStandardConfig.cginc"
    #include "UnityGlobalIllumination.cginc"
    #include "UnityStandardUtils.cginc"
    #include "UnityGBuffer.cginc"
    #include "UnityStandardBRDF.cginc"
    #include "UnityPBSLighting.cginc"
    #include "AutoLight.cginc"

    // #include "Fur_newmodel.cginc"
    #include "Fur_UnityStandardInput.cginc"
    #include "Fur_BRDF.cginc"
    //-------------------------------------------------------------------------------------
    // counterpart for NormalizePerPixelNormal
    // skips normalization per-vertex and expects normalization to happen per-pixel
    half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow
    {
        #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
            return normalize(n);
        #else
            return n; // will normalize per-pixel instead
        #endif
    }

    float3 NormalizePerPixelNormal (float3 n)
    {
        #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
            return n;
        #else
            return normalize(n);
        #endif
    }

    //-------------------------------------------------------------------------------------
    UnityLight MainLight ()
    {
        UnityLight l;

        l.color = _LightColor0.rgb;
        l.dir = _WorldSpaceLightPos0.xyz;
        return l;
    }

    UnityLight AdditiveLight (half3 lightDir, half atten)
    {
        UnityLight l;

        l.color = _LightColor0.rgb;
        l.dir = lightDir;
        #ifndef USING_DIRECTIONAL_LIGHT
            l.dir = NormalizePerPixelNormal(l.dir);
        #endif

        // shadow the light
        l.color *= atten;
        return l;
    }

    UnityLight DummyLight ()
    {
        UnityLight l;
        l.color = 0;
        l.dir = half3 (0,1,0);
        return l;
    }

    UnityIndirect ZeroIndirect ()
    {
        UnityIndirect ind;
        ind.diffuse = 0;
        ind.specular = 0;
        return ind;
    }

    //-------------------------------------------------------------------------------------
    // Common fragment setup

    // deprecated
    half3 WorldNormal(half4 tan2world[3])
    {
        return normalize(tan2world[2].xyz);
    }

    // deprecated
    #ifdef _TANGENT_TO_WORLD
        half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
        {
            half3 t = tan2world[0].xyz;
            half3 b = tan2world[1].xyz;
            half3 n = tan2world[2].xyz;

            #if UNITY_TANGENT_ORTHONORMALIZE
                n = NormalizePerPixelNormal(n);

                // ortho-normalize Tangent
                t = normalize (t - n * dot(t, n));

                // recalculate Binormal
                half3 newB = cross(n, t);
                b = newB * sign (dot (newB, b));
            #endif

            return half3x3(t, b, n);
        }
    #else
        half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
        {
            return half3x3(0,0,0,0,0,0,0,0,0);
        }
    #endif

    float3 PerPixelWorldNormal(float4 i_tex, float4 tangentToWorld[3], out float3 normalWorld_clearcoat)
    {
        #ifdef _NORMALMAP
            half3 tangent = tangentToWorld[0].xyz;
            half3 binormal = tangentToWorld[1].xyz;
            half3 normal = tangentToWorld[2].xyz;

            #if UNITY_TANGENT_ORTHONORMALIZE
                normal = NormalizePerPixelNormal(normal);

                // ortho-normalize Tangent
                tangent = normalize (tangent - normal * dot(tangent, normal));

                // recalculate Binormal
                half3 newB = cross(normal, tangent);
                binormal = newB * sign (dot (newB, binormal));
            #endif

            half3 normalTangent_flake;

            half3 normalTangent = NormalInTangentSpace(i_tex, /*out*/ normalTangent_flake);
            float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well

            normalWorld_clearcoat = normalWorld;
            #if _FLAKENORMAL
                normalWorld = NormalizePerPixelNormal(tangent * normalTangent_flake.x + binormal * normalTangent_flake.y + normal * normalTangent_flake.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
            #endif
            
        #else
            float3 normalWorld = normalize(tangentToWorld[2].xyz);
            normalWorld_clearcoat = normalWorld;
        #endif

        return normalWorld;
    }

    #ifdef _PARALLAXMAP
        #define IN_VIEWDIR4PARALLAX(i) NormalizePerPixelNormal(half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w))
        #define IN_VIEWDIR4PARALLAX_FWDADD(i) NormalizePerPixelNormal(i.viewDirForParallax.xyz)
    #else
        #define IN_VIEWDIR4PARALLAX(i) half3(0,0,0)
        #define IN_VIEWDIR4PARALLAX_FWDADD(i) half3(0,0,0)
    #endif

    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            #define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)
        #else
            #define IN_WORLDPOS(i) i.posWorld
        #endif
        #define IN_WORLDPOS_FWDADD(i) i.posWorld
    #else
        #define IN_WORLDPOS(i) half3(0,0,0)
        #define IN_WORLDPOS_FWDADD(i) half3(0,0,0)
    #endif

    #define IN_LIGHTDIR_FWDADD(i) half3(i.tangentToWorldAndLightDir[0].w, i.tangentToWorldAndLightDir[1].w, i.tangentToWorldAndLightDir[2].w)

    #define FRAGMENT_SETUP(x) FragmentCommonData x = \
    FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i), facing);

    #define FRAGMENT_SETUP_FWDADD(x) FragmentCommonData x = \
    FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i));

    struct FragmentCommonData
    {
        half3 diffColor, specColor;
        // Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
        // Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
        half oneMinusReflectivity, smoothness;
        float3 normalWorld, normalWorld_clearcoat;
        float3 tangentWorld;
        float3 eyeVec;
        half alpha;
        float3 posWorld;



        #if UNITY_STANDARD_SIMPLE
            half3 reflUVW;
        #endif

        #if UNITY_STANDARD_SIMPLE
            half3 tangentSpaceNormal;
        #endif
    };

    #ifndef UNITY_SETUP_BRDF_INPUT
        #define UNITY_SETUP_BRDF_INPUT SpecularSetup
    #endif

    inline FragmentCommonData SpecularSetup (float4 i_tex)
    {
        half4 specGloss = SpecularGloss(i_tex.xy);
        half3 specColor = specGloss.rgb;
        half smoothness = specGloss.a;

        half oneMinusReflectivity;
        half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);

        FragmentCommonData o = (FragmentCommonData)0;
        o.diffColor = diffColor;
        o.specColor = specColor;
        o.oneMinusReflectivity = oneMinusReflectivity;
        o.smoothness = smoothness;
        return o;
    }

    inline FragmentCommonData RoughnessSetup(float4 i_tex)
    {
        half2 metallicGloss = MetallicRough(i_tex.xy);
        half metallic = metallicGloss.x;
        half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

        half oneMinusReflectivity;
        half3 specColor;
        half3 diffColor = DiffuseAndSpecularFromMetallic(Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

        FragmentCommonData o = (FragmentCommonData)0;
        o.diffColor = diffColor;
        o.specColor = specColor;
        o.oneMinusReflectivity = oneMinusReflectivity;
        o.smoothness = smoothness;
        return o;
    }

    inline FragmentCommonData MetallicSetup (float4 i_tex)
    {
        half2 metallicGloss = MetallicGloss(i_tex.xy);
        half metallic = metallicGloss.x;
        half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

        half oneMinusReflectivity;
        half3 specColor;
        half3 diffColor = DiffuseAndSpecularFromMetallic (Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

        FragmentCommonData o = (FragmentCommonData)0;
        o.diffColor = diffColor;
        o.specColor = specColor;
        o.oneMinusReflectivity = oneMinusReflectivity;
        o.smoothness = smoothness;
        return o;
    }

    // parallax transformed texcoord is used to sample occlusion
    inline FragmentCommonData FragmentSetup (inout float4 i_tex, float3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld, half facing = 1)
    {
        i_tex = Parallax(i_tex, i_viewDirForParallax);

        half alpha = Alpha(i_tex.xy);
        #if defined(_ALPHATEST_ON)
            clip (alpha - _Cutoff);
        #endif

        FragmentCommonData o = UNITY_SETUP_BRDF_INPUT (i_tex);
        o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld, /*out*/ o.normalWorld_clearcoat);
        o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
        o.posWorld = i_posWorld;

        #if _HAIR 
            half3 TangentDir = half3(sqrt(1 - _TangentDir * _TangentDir) ,_TangentDir, 0);
            o.tangentWorld = NormalizePerPixelNormal(normalize(tangentToWorld[0].xyz) * TangentDir.x + normalize(tangentToWorld[1].xyz) * TangentDir.y) * facing;
        #elif _TENLAYERS || _FUR
            // half3 TangentDir = half3(sqrt(1 - _TangentDir * _TangentDir) ,_TangentDir, 0);
            // o.tangentWorld = NormalizePerPixelNormal(normalize(tangentToWorld[0].xyz) * TangentDir.x + normalize(tangentToWorld[1].xyz) * TangentDir.y) * facing;
            o.tangentWorld=tangentToWorld[2].xyz;
        #else
            o.tangentWorld = tangentToWorld[0].xyz;
        #endif

        // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
        o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
        return o;
    }

    inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light, bool reflections)
    {
        UnityGIInput d;
        d.light = light;
        d.worldPos = s.posWorld;
        d.worldViewDir = -s.eyeVec;
        d.atten = atten;
        #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
            d.ambient = 0;
            d.lightmapUV = i_ambientOrLightmapUV;
        #else
            d.ambient = i_ambientOrLightmapUV.rgb;
            d.lightmapUV = 0;
        #endif

        d.probeHDR[0] = unity_SpecCube0_HDR;
        d.probeHDR[1] = unity_SpecCube1_HDR;
        #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
            d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
        #endif
        #ifdef UNITY_SPECCUBE_BOX_PROJECTION
            d.boxMax[0] = unity_SpecCube0_BoxMax;
            d.probePosition[0] = unity_SpecCube0_ProbePosition;
            d.boxMax[1] = unity_SpecCube1_BoxMax;
            d.boxMin[1] = unity_SpecCube1_BoxMin;
            d.probePosition[1] = unity_SpecCube1_ProbePosition;
        #endif

        if(reflections)
        {
            Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.smoothness, -s.eyeVec, s.normalWorld, s.specColor);
            // Replace the reflUVW if it has been compute in Vertex shader. Note: the compiler will optimize the calcul in UnityGlossyEnvironmentSetup itself
            #if UNITY_STANDARD_SIMPLE
                g.reflUVW = s.reflUVW;
            #endif

            return UnityGlobalIllumination (d, occlusion, s.normalWorld, g);
        }
        else
        {
            return UnityGlobalIllumination (d, occlusion, s.normalWorld);
        }
    }

    inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light)
    {
        return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, true);
    }


    //-------------------------------------------------------------------------------------
    half4 OutputForward (half4 output, half alphaFromSurface)
    {
        #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
            output.a = alphaFromSurface;
        #else
            UNITY_OPAQUE_ALPHA(output.a);
        #endif
        return output;
    }

    inline half4 VertexGIForward(VertexInput v, float3 posWorld, half3 normalWorld)
    {
        half4 ambientOrLightmapUV = 0;
        // Static lightmaps
        #ifdef LIGHTMAP_ON
            ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            ambientOrLightmapUV.zw = 0;
            // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
        #elif UNITY_SHOULD_SAMPLE_SH
            #ifdef VERTEXLIGHT_ON
                // Approximated illumination from non-important point lights
                ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
            #endif

            ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
        #endif

        #ifdef DYNAMICLIGHTMAP_ON
            ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
        #endif

        return ambientOrLightmapUV;
    }

    // ------------------------------------------------------------------
    //  Base forward pass (directional light, emission, lightmaps, ...)

    struct VertexOutputForwardBase
    {
        UNITY_POSITION(pos);
        float4 tex                            : TEXCOORD0;
        float3 eyeVec                         : TEXCOORD1;
        float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
        half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV
        UNITY_LIGHTING_COORDS(6,7)

        // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
        #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
            float3 posWorld                     : TEXCOORD8;
        #endif

        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    VertexOutputForwardBase vertForwardBase(VertexInput v, half FUR_OFFSET = 0)
    {
        UNITY_SETUP_INSTANCE_ID(v);
        VertexOutputForwardBase o;
        UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.tex = TexCoords(v);
        //
        //o.tex.zw*=FUR_OFFSET*5;

        #if _FUR
            // fixed noise = tex2D(_LayerTex, fixed2(1,1)).r;
            //fixed noise=1;
            // v.normal.z*=noise;
            // v.normal=normalize(v.normal);
            fixed3 samplenormal=tex2Dlod(_ForceMap,float4(TRANSFORM_TEX(o.tex.xy,_ForceMap),0,0)).rgb;

            fixed3 forcenormal=(samplenormal-fixed3(0.5,0.5,0.5))*2;

            //fixed3 binormal=cross(v.normal,v.tangent)*v.tangent.w;

            // half3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength), FUR_OFFSET);

            // half3 direction = lerp(v.normal, _ForceMapScale*forcenormal + v.normal * (1 - _ForceMapScale), FUR_OFFSET);
            half3 turbulent=_ForceMapScale*forcenormal+ (-v.tangent)  * (1 - _ForceMapScale);
            half3 tipdir=lerp(turbulent,v.normal,1-_ForceMapScale);
            half3 direction = lerp(v.normal, tipdir, FUR_OFFSET);

            //physically rotation********************************************************************

            half3 goaldir=normalize(_Gravity);
            direction=(1-_GravityStrength)*direction+_GravityStrength*goaldir;
            // if(_GravityStrength>0)
            // {direction=lerp(direction,v.tangent,_GravityStrength);}
            // else
            // {direction=lerp(direction,-v.tangent,-_GravityStrength);}

            //end************************************************************************************

            //physically rotation********************************************************************
            // half3 rotateWorld=mul(unity_ObjectToWorld,float4(0,1,0,1)).xyz;//y-rotation

            // half3 pointTo=float3(v.vertex.x-rotateWorld.x,0,v.vertex.z-rotateWorld.z);

            // half3 rotateDir=normalize(cross(float3(0,1,0),pointTo));
            // //use fur_offset to lerp your scale
            // //use sqrt to adjust the action of fur's roots
            // if(_GravityStrength>0)
            // {direction=lerp(direction,lerp(direction,rotateDir,_GravityStrength),FUR_OFFSET);}
            // else
            // {direction=lerp(direction,lerp(direction,-rotateDir,-_GravityStrength),FUR_OFFSET);}
            //end************************************************************************************

            direction=normalize(direction);

            float theta=dot(v.normal,direction);
            //use GrowthMap to control the length of fur
            fixed length_control=tex2Dlod(_FurGrowthMap,float4(TRANSFORM_TEX(o.tex.xy,_FurGrowthMap),0,0)).r;
            //multiply theta to narrow the gap between layers
            v.vertex.xyz += direction * _FurLength*pow(length_control,_FurGrowth) * FUR_OFFSET *theta*theta;
        #endif 

        float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
        #if UNITY_REQUIRE_FRAG_WORLDPOS
            #if UNITY_PACK_WORLDPOS_WITH_TANGENT
                o.tangentToWorldAndPackedData[0].w = posWorld.x;
                o.tangentToWorldAndPackedData[1].w = posWorld.y;
                o.tangentToWorldAndPackedData[2].w = posWorld.z;
            #else
                o.posWorld = posWorld.xyz;
            #endif
        #endif
        o.pos = UnityObjectToClipPos(v.vertex);

        
        o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
        float3 normalWorld = UnityObjectToWorldNormal(v.normal);
        #ifdef _TANGENT_TO_WORLD
            //float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

            //float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);

            //transform matrix 
            o.tangentToWorldAndPackedData[0].xyz = half3(1,0,0);//random value
            o.tangentToWorldAndPackedData[1].xyz = half3(0,1,0);
            //o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
            o.tangentToWorldAndPackedData[2].xyz = UnityObjectToWorldNormal(direction);
        #else
            o.tangentToWorldAndPackedData[0].xyz = 0;
            o.tangentToWorldAndPackedData[1].xyz = 0;
            o.tangentToWorldAndPackedData[2].xyz = normalWorld;
        #endif

        //We need this for shadow receving
        UNITY_TRANSFER_LIGHTING(o, v.uv1);

        o.ambientOrLightmapUV = VertexGIForward(v, posWorld, normalWorld);

        #ifdef _PARALLAXMAP
            TANGENT_SPACE_ROTATION;
            half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
            o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
            o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
            o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
        #endif

        UNITY_TRANSFER_FOG(o,o.pos);
        return o;
    }
    //fragment Shader
    half4 fragForwardBaseInternal (VertexOutputForwardBase i, half FUR_OFFSET = 0,half FUR_DENSITY = 1)
    {
        UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

        half facing = dot(-i.eyeVec, i.tangentToWorldAndPackedData[2].xyz);
        facing = saturate(ceil(facing)) * 2 - 1;

        FRAGMENT_SETUP(s)

        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UnityLight mainLight = MainLight ();
        UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

        half occlusion = Occlusion(i.tex.xy);

        UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

        
        //half4 anisoMap = tex2D(_AnisoMap, TRANSFORM_TEX(i.tex.xy, _AnisoMap));

        #if defined(_BRDF)
            half4 c = FUR_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect, s.tangentWorld);
        #elif defined(_KK)
            half4 c = KajiyaFurShading(s.diffColor,s.specColor,s.smoothness,-s.eyeVec,s.tangentWorld,s.normalWorld,gi.light,gi.indirect);
        #endif

        c.rgb += Emission(i.tex.xy);

        //fur_tip color
        #ifdef _TIPLOCATEMAP
            float is_tip=tex2D(_TipLocateMap,TRANSFORM_TEX(i.tex.xy,_TipLocateMap)).r;
            //c.rgb=lerp(c.rgb,_TipColor.rgb,_TipChoice*pow(FUR_OFFSET,_TipControl)*(1-dot(-s.eyeVec, s.normalWorld)));
            //c.rgb=lerp(c.rgb,_TipColor.rgb,1-is_tip);
            c.rgb=lerp(c.rgb,_TipColor.rgb,is_tip);
        #endif

        UNITY_APPLY_FOG(i.fogCoord, c.rgb);

        #if _FUR_OPT

            fixed alpha = tex2D(_LayerTex, TRANSFORM_TEX(i.tex.zw, _LayerTex)).r;

            //float cut_offset = ();
            alpha =step(lerp(_Cutoff, _CutoffEnd, FUR_OFFSET), alpha);

            c.rgb*=pow(max(FUR_OFFSET,0.2),_AO);

            c.a = (1 - FUR_OFFSET * FUR_OFFSET) /  FUR_DENSITY;

            //EdgeFade
            c.a += dot(-s.eyeVec, s.normalWorld) - _EdgeFade;

            c.a = max(0, c.a);
            c.a *= alpha;

            c.a = clamp(c.a, 0.f, 1.f);
            return c;
        #else
        #if _FUR
            fixed alpha = tex2D(_LayerTex, TRANSFORM_TEX(i.tex.zw, _LayerTex)).r;

            alpha =step(lerp(_Cutoff, _CutoffEnd, FUR_OFFSET), alpha);

            c.rgb*=pow(max(FUR_OFFSET,0.2),_AO);

            c.a = 1 - FUR_OFFSET*FUR_OFFSET;
            //c.a = 1;

            //EdgeFade
            c.a += dot(-s.eyeVec, s.normalWorld) - _EdgeFade;

            c.a = max(0, c.a);
            c.a *= alpha;
            //return half4(0.,0.,0.,c.a);
            return c;
        #endif //_FUR

        #endif //_FUR_OPT

        return OutputForward(c, s.alpha);
    }

    half4 fragForwardBase(VertexOutputForwardBase i) : SV_Target // backward compatibility (this used to be the fragment entry function)
    {
        return fragForwardBaseInternal(i);
    }

    // ------------------------------------------------------------------
    //  Additive forward pass (one light per pass)

    struct VertexOutputForwardAdd
    {
        UNITY_POSITION(pos);
        float4 tex                          : TEXCOORD0;
        float3 eyeVec                       : TEXCOORD1;
        float4 tangentToWorldAndLightDir[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
        float3 posWorld                     : TEXCOORD5;
        UNITY_LIGHTING_COORDS(6, 7)

        // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
        #if defined(_PARALLAXMAP)
            half3 viewDirForParallax            : TEXCOORD8;
        #endif

        UNITY_VERTEX_OUTPUT_STEREO
    };

    VertexOutputForwardAdd vertForwardAdd (VertexInput v)
    {
        UNITY_SETUP_INSTANCE_ID(v);
        VertexOutputForwardAdd o;
        UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
        o.pos = UnityObjectToClipPos(v.vertex);

        o.tex = TexCoords(v);
        o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
        o.posWorld = posWorld.xyz;
        float3 normalWorld = UnityObjectToWorldNormal(v.normal);
        #ifdef _TANGENT_TO_WORLD
            float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

            float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
            o.tangentToWorldAndLightDir[0].xyz = tangentToWorld[0];
            o.tangentToWorldAndLightDir[1].xyz = tangentToWorld[1];
            o.tangentToWorldAndLightDir[2].xyz = tangentToWorld[2];
        #else
            o.tangentToWorldAndLightDir[0].xyz = 0;
            o.tangentToWorldAndLightDir[1].xyz = 0;
            o.tangentToWorldAndLightDir[2].xyz = normalWorld;
        #endif
        //We need this for shadow receiving and lighting
        UNITY_TRANSFER_LIGHTING(o, v.uv1);

        float3 lightDir = _WorldSpaceLightPos0.xyz - posWorld.xyz * _WorldSpaceLightPos0.w;
        #ifndef USING_DIRECTIONAL_LIGHT
            lightDir = NormalizePerVertexNormal(lightDir);
        #endif
        o.tangentToWorldAndLightDir[0].w = lightDir.x;
        o.tangentToWorldAndLightDir[1].w = lightDir.y;
        o.tangentToWorldAndLightDir[2].w = lightDir.z;

        #ifdef _PARALLAXMAP
            TANGENT_SPACE_ROTATION;
            o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        #endif

        UNITY_TRANSFER_FOG(o,o.pos);
        return o;
    }

    half4 fragForwardAddInternal (VertexOutputForwardAdd i)
    {
        UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        FRAGMENT_SETUP_FWDADD(s)

        UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
        UnityLight light = AdditiveLight (IN_LIGHTDIR_FWDADD(i), atten);
        UnityIndirect noIndirect = ZeroIndirect ();

        
        half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);
        
        UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
        UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
        return OutputForward (c, s.alpha);
    }

    half4 fragForwardAdd (VertexOutputForwardAdd i) : SV_Target     // backward compatibility (this used to be the fragment entry function)
    {
        return fragForwardAddInternal(i);
    }

    //
    // Old FragmentGI signature. Kept only for backward compatibility and will be removed soon
    //

    inline UnityGI FragmentGI(
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light,
    bool reflections)
    {
        // we init only fields actually used
        FragmentCommonData s = (FragmentCommonData)0;
        s.smoothness = smoothness;
        s.normalWorld = normalWorld;
        s.eyeVec = eyeVec;
        s.posWorld = posWorld;
        return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, reflections);
    }
    inline UnityGI FragmentGI (
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light)
    {
        return FragmentGI (posWorld, occlusion, i_ambientOrLightmapUV, atten, smoothness, normalWorld, eyeVec, light, true);
    }

#endif // UNITY_STANDARD_CORE_INCLUDED
