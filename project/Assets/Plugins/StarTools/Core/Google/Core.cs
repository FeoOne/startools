using UnityEngine;

namespace StarTools.Core.Google
{
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    public static class Core
    {
        public static void Setup()
        {
            new AndroidJavaClass("com.feosoftware.startools.core.Core").CallStatic("setup");
        }
    }
#endif
}
