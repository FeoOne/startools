using UnityEngine;

namespace StarTools.Core.Google
{
    public static class Core
    {
        public static void Setup()
        {
            new AndroidJavaClass("com.feosoftware.startools.core.Core").CallStatic("setup");
        }
    }
}