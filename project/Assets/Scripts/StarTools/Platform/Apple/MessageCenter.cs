using System;
using System.Runtime.InteropServices;

namespace StarTools.Platform.Apple
{
    public static class MessageCenter
    {
        private delegate void MessageDelegate(string message, string data);
        
        private static Action<string, string> _onMessage;

        [AOT.MonoPInvokeCallback(typeof(MessageDelegate))]
        private static void OnMessage(string message, string data)
        {
            _onMessage.Invoke(message, data);
        }

        [DllImport("__Internal")]
        private static extern void RegisterMessageCenterDelegate(MessageDelegate messageDelegate);
        
        public static void Setup(Action<string, string> onMessage)
        {
            _onMessage = onMessage;
            
            RegisterMessageCenterDelegate(OnMessage);
        }
    }
}
