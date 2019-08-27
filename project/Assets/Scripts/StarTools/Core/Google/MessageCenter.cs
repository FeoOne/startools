namespace StarTools.Core.Google
{
    public static class MessageCenter
    {
        private class JavaMessageHandler : AndroidJavaProxy
        {
            public JavaMessageHandler() : base("com.startools.MessageHandler") { }

            public void OnMessage(string message, string data)
            {
                // todo
            }
        }

        private static AndroidJavaClass _bridgeJavaClass;
        
        public static void Setup()
        {
            _bridgeJavaClass = new AndroidJavaClass("com.startools.UnityBridge");
            _bridgeJavaClass.CallStatic("registerMessageHandler", new JavaMessageHandler());
        }
    }
}
