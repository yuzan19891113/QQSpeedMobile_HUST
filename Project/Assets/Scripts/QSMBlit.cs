
using UnityEngine;
using System.Collections;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
[DisallowMultipleComponent, ImageEffectAllowedInSceneView]
public class QSMBlit : MonoBehaviour
{
    public static bool IsShowOverDrawState;
    public static bool UseBlit = true;

    #region Variables

    public Shader SCShader;
    // 无论是否为UI，是否含有RT，保持enable如果AlwaysEnable
    //  但与后处理的互斥还需保持
    public bool AlwaysEnable = false;

    [Header("默认转Gamma，勾选为转Linear")]
    public bool ToLinear;


    [Header("默认快速版本，勾选为精确版本")]
    public bool UseExactVersion = false;
    private string ShaderFullName
    {
        get
        {
            return ToLinear ? "Hidden/QSMBlitToLinear" : (UseExactVersion ? "Hidden/QSMBlit_Exact" : "Hidden/QSMBlit");
        }
    }

    private Material SCMaterial;

    #endregion

    #region Properties
    Material material
    {
        get
        {
            if (SCMaterial == null)
            {
                SCMaterial = new Material(SCShader);
                SCMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return SCMaterial;
        }
    }
    #endregion
    void Start()
    {
#if UNITY_EDITOR
        SCShader = UseExactVersion ? AssetDatabase.LoadAssetAtPath<Shader>("Assets/ResForAssetBundles/0BaseCommon/Shaders/QSMBlit_Exact.shader"):AssetDatabase.LoadAssetAtPath<Shader>("Assets/ResForAssetBundles/0BaseCommon/Shaders/QSMBlit.shader");
#else
        SCShader = GamePub.GetInstance().GetModule<IResMdl>(this).FindShader(ShaderFullName);
#endif
    }

   // [ImageEffectTransprarentLast]
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (IsShowOverDrawState)
            return;

        //if (UseBlit)
        {
            if (SCShader != null)
            {
                Graphics.Blit(sourceTexture, destTexture, material);
            }
            else
            {
                Graphics.Blit(sourceTexture, destTexture);
            }
        }
    }

    private void OnValidate()
    {
        if (SCMaterial)
        {
            DestroyImmediate(SCMaterial);
        }
    }

    void Update()
    {
#if UNITY_EDITOR
        if (Application.isPlaying != true)
        {
            SCShader = UseExactVersion ? AssetDatabase.LoadAssetAtPath<Shader>("Assets/ResForAssetBundles/0BaseCommon/Shaders/QSMBlit_Exact.shader") : AssetDatabase.LoadAssetAtPath<Shader>("Assets/ResForAssetBundles/0BaseCommon/Shaders/QSMBlit.shader");
        }
#endif
    }

    void OnDisable()
    {
        if (SCMaterial)
        {
            DestroyImmediate(SCMaterial);
        }
    }

}
