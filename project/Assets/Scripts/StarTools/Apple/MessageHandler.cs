using System.Runtime.InteropServices;

namespace StarTools.Apple
{
    public static class MessageHandler
    {
        private delegate void MessageDelegate(string message, string data);

        [AOT.MonoPInvokeCallback(typeof(MessageDelegate))]
        private static void OnMessage(string message, string data)
        {
            // todo
        }

        [DllImport("__Internal")]
        private static extern void RegisterMessageHandler(MessageDelegate messageDelegate);
        
        public static void Setup()
        {
            RegisterMessageHandler(OnMessage);
        }
    }
}
