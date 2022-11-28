// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef FUR_UNITY_STANDARD_CORE_FORWARD_INCLUDED
    #define FUR_UNITY_STANDARD_CORE_FORWARD_INCLUDED

    #if defined(UNITY_NO_FULL_STANDARD_SHADER)
        #   define UNITY_STANDARD_SIMPLE 1
    #endif

    #include "UnityStandardConfig.cginc"

    #if 0
        #include "UnityStandardCoreForwardSimple.cginc"
        VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
        VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }
        half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); }
        half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); }
    #else
        #include "Fur_UnityStandardCore.cginc"
        VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
        VertexOutputForwardBase vertAdd (VertexInput v) { return vertForwardBase(v,0.95); }
        half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i); }
        half4 fragAdd (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i,0.95); }

        #ifdef _FUR_OPT

            #define FUR_OFFSET_L7 0.15
            #define FUR_OFFSET_L8 0.3
            #define FUR_OFFSET_L9 0.45
            #define FUR_OFFSET_L10 0.6
            #define FUR_OFFSET_L11 0.65
            #define FUR_OFFSET_L12 0.7
            #define FUR_OFFSET_L13 0.75
            #define FUR_OFFSET_L14 0.8
            #define FUR_OFFSET_L15 0.85
            #define FUR_OFFSET_L16 0.9

            #define FUR_DENSITY_L7 0.25
            #define FUR_DENSITY_L8 0.25
            #define FUR_DENSITY_L9 0.25
            #define FUR_DENSITY_L10 1.167
            #define FUR_DENSITY_L11 1.167
            #define FUR_DENSITY_L12 1.167
            #define FUR_DENSITY_L13 1.167
            #define FUR_DENSITY_L14 1.167
            #define FUR_DENSITY_L15 1.167
            #define FUR_DENSITY_L16 1.167


//#define OptFurFramgmentOutput(L) float4 c = fragForwardBaseInternal(i, FUR_OFFSET_##L); c.a /= FUR_DENSITY_##L;  return c;
#define OptFurFramgmentOutput(L) float4 c = fragForwardBaseInternal(i, FUR_OFFSET_##L,FUR_OFFSET_##L); return c;

            VertexOutputForwardBase vertBase_FurLayer7(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L7);}
            VertexOutputForwardBase vertBase_FurLayer8(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L8);}
            VertexOutputForwardBase vertBase_FurLayer9(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L9);}
            VertexOutputForwardBase vertBase_FurLayer10(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L10);}
            VertexOutputForwardBase vertBase_FurLayer11(VertexInput v) { return vertForwardBase(v,FUR_OFFSET_L11);}
            VertexOutputForwardBase vertBase_FurLayer12(VertexInput v) { return vertForwardBase(v,FUR_OFFSET_L12);}
            VertexOutputForwardBase vertBase_FurLayer13(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L13);}
            VertexOutputForwardBase vertBase_FurLayer14(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L14);}
            VertexOutputForwardBase vertBase_FurLayer15(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L15);}
            VertexOutputForwardBase vertBase_FurLayer16(VertexInput v) { return vertForwardBase(v, FUR_OFFSET_L16);}
            
            half4 fragBase_FurLayer7 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L7) }
            half4 fragBase_FurLayer8 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L8) }
            half4 fragBase_FurLayer9 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L9) }
            half4 fragBase_FurLayer10 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L10) }
            half4 fragBase_FurLayer11 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L11) }
            half4 fragBase_FurLayer12 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L12) }
            half4 fragBase_FurLayer13 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L13) }
            half4 fragBase_FurLayer14 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L14) }
            half4 fragBase_FurLayer15 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L15) }
            half4 fragBase_FurLayer16 (VertexOutputForwardBase i) : SV_Target { OptFurFramgmentOutput(L16) }
            

        #else


        #ifdef _TENLAYERS
            VertexOutputForwardBase vertBase_FurLayer1(VertexInput v) { return vertForwardBase(v, 0.05);}
            VertexOutputForwardBase vertBase_FurLayer2(VertexInput v) { return vertForwardBase(v, 0.1);}
            VertexOutputForwardBase vertBase_FurLayer3(VertexInput v) { return vertForwardBase(v, 0.15);}
            VertexOutputForwardBase vertBase_FurLayer4(VertexInput v) { return vertForwardBase(v, 0.2);}
            VertexOutputForwardBase vertBase_FurLayer5(VertexInput v) { return vertForwardBase(v, 0.25);}
            VertexOutputForwardBase vertBase_FurLayer6(VertexInput v) { return vertForwardBase(v, 0.3);}
            VertexOutputForwardBase vertBase_FurLayer7(VertexInput v) { return vertForwardBase(v, 0.35);}
            VertexOutputForwardBase vertBase_FurLayer8(VertexInput v) { return vertForwardBase(v, 0.4);}
            VertexOutputForwardBase vertBase_FurLayer9(VertexInput v) { return vertForwardBase(v, 0.45);}
            VertexOutputForwardBase vertBase_FurLayer10(VertexInput v) { return vertForwardBase(v, 0.5);}
            VertexOutputForwardBase vertBase_FurLayer11(VertexInput v) { return vertForwardBase(v, 0.55);}
            VertexOutputForwardBase vertBase_FurLayer12(VertexInput v) { return vertForwardBase(v, 0.6);}
            VertexOutputForwardBase vertBase_FurLayer13(VertexInput v) { return vertForwardBase(v, 0.65);}
            VertexOutputForwardBase vertBase_FurLayer14(VertexInput v) { return vertForwardBase(v, 0.7);}
            VertexOutputForwardBase vertBase_FurLayer15(VertexInput v) { return vertForwardBase(v, 0.75);}
            VertexOutputForwardBase vertBase_FurLayer16(VertexInput v) { return vertForwardBase(v, 0.8);}
            VertexOutputForwardBase vertBase_FurLayer17(VertexInput v) { return vertForwardBase(v, 0.85);}
            VertexOutputForwardBase vertBase_FurLayer18(VertexInput v) { return vertForwardBase(v, 0.9);}
            VertexOutputForwardBase vertBase_FurLayer19(VertexInput v) { return vertForwardBase(v, 0.95);}
            VertexOutputForwardBase vertBase_FurLayer20(VertexInput v) { return vertForwardBase(v, 1);}

            half4 fragBase_FurLayer1 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.05); }
            half4 fragBase_FurLayer2 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.1); }
            half4 fragBase_FurLayer3 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.15); }
            half4 fragBase_FurLayer4 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.2); }
            half4 fragBase_FurLayer5 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.25); }
            half4 fragBase_FurLayer6 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.3); }
            half4 fragBase_FurLayer7 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.35); }
            half4 fragBase_FurLayer8 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.4); }
            half4 fragBase_FurLayer9 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.45); }
            half4 fragBase_FurLayer10 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.5); }
            half4 fragBase_FurLayer11 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.55); }
            half4 fragBase_FurLayer12 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.6); }
            half4 fragBase_FurLayer13 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.65); }
            half4 fragBase_FurLayer14 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.7); }
            half4 fragBase_FurLayer15 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.75); }
            half4 fragBase_FurLayer16 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.8); }
            half4 fragBase_FurLayer17 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.85); }
            half4 fragBase_FurLayer18 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.9); }
            half4 fragBase_FurLayer19 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.95); }
            half4 fragBase_FurLayer20 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 1); }
        #else
            VertexOutputForwardBase vertBase_FurLayer1(VertexInput v) { return vertForwardBase(v, 0.1);}
            VertexOutputForwardBase vertBase_FurLayer2(VertexInput v) { return vertForwardBase(v, 0.2);}
            VertexOutputForwardBase vertBase_FurLayer3(VertexInput v) { return vertForwardBase(v, 0.3);}
            VertexOutputForwardBase vertBase_FurLayer4(VertexInput v) { return vertForwardBase(v, 0.4);}
            VertexOutputForwardBase vertBase_FurLayer5(VertexInput v) { return vertForwardBase(v, 0.5);}
            VertexOutputForwardBase vertBase_FurLayer6(VertexInput v) { return vertForwardBase(v, 0.6);}
            VertexOutputForwardBase vertBase_FurLayer7(VertexInput v) { return vertForwardBase(v, 0.7);}
            VertexOutputForwardBase vertBase_FurLayer8(VertexInput v) { return vertForwardBase(v, 0.8);}
            VertexOutputForwardBase vertBase_FurLayer9(VertexInput v) { return vertForwardBase(v, 0.9);}
            VertexOutputForwardBase vertBase_FurLayer10(VertexInput v) { return vertForwardBase(v, 1.0);}

            half4 fragBase_FurLayer1 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.1); }
            half4 fragBase_FurLayer2 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.2); }
            half4 fragBase_FurLayer3 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.3); }
            half4 fragBase_FurLayer4 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.4); }
            half4 fragBase_FurLayer5 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.5); }
            half4 fragBase_FurLayer6 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.6); }
            half4 fragBase_FurLayer7 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.7); }
            half4 fragBase_FurLayer8 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.8); }
            half4 fragBase_FurLayer9 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.9); }
            half4 fragBase_FurLayer10 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 1.0); }
        #endif

        #endif
    #endif

#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED
