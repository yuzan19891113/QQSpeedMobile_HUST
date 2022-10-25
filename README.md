# QQSpeedMobile_HUST

[TOC]



## 纱（yarn）材质使用方法

图片*albedo1*放入*Warp And Weft*槽

*judge3*放入*Judge*槽

*n_test3-1*为经纬线法线贴图，放入*secondary maps*中的*normal map*槽

噪声贴图放入*Specular*槽

**注意**：因为种种原因，*Specular、Warp And Weft、Judge*槽的tilling和offset参数无法使用，并且这三个槽的tilling应当相同。所以请使用*density*参数共同控制三者的tilling并确保其和经纬线法线贴图的tilling保持一致

**注：参数有所修改，具体使用方法以pdf为准**

## 毛皮（fur）材质使用方法

layerMap放入Tip Locate Map和Layer Map槽

ForceMap放入ForceMap槽

layer1放入Fur Height Map槽

抖动贴图放入AnisoMap槽

此材质中的所有tilling和offset参数都可正常使用

**注：参数有所修改，具体使用方法以pdf为准**