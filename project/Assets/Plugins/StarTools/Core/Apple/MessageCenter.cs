using System;
using System.Runtime.InteropServices;

namespace StarTools.Core.Apple
{
    public static class MessageCenter
    {
        private delegate void MessageDelegate(string message, string data);
        
        [DllImport("__Internal")]
        private static extern void StarTools_RegisterMessageCenterDelegate(MessageDelegate messageDelegate);
        
        private static Action<string, string> _onMessageManagedAction;

        [AOT.MonoPInvokeCallback(typeof(MessageDelegate))]
        private static void OnMessage(string message, string data)
        {
            _onMessageManagedAction?.Invoke(message, data);
        }

        public static void Setup(Action<string, string> onMessage)
        {
            _onMessageManagedAction = onMessage;
            
            StarTools_RegisterMessageCenterDelegate(OnMessage);
        }
    }
}
