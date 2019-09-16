using System;
using UnityEngine;

namespace StarTools.Core.Google
{
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    public static class MessageCenter
    {
        private static Action<string, string> _onMessageManagedAction;
        
        private sealed class JavaMessageCenter : AndroidJavaProxy
        {
            public JavaMessageCenter() : base("com.feosoftware.startools.core.MessageCenter") { }

            public void OnMessage(string message, string data)
            {
                _onMessageManagedAction?.Invoke(message, data);
            }
        }

        public static void Setup(Action<string, string> onMessage)
        {
            _onMessageManagedAction = onMessage;
            
            new AndroidJavaClass("com.feosoftware.startools.core.Core")
                .CallStatic("registerMessageCenterHandler", new JavaMessageCenter());
        }
    }
#endif
}
