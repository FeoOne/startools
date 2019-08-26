using System;
using System.Runtime.InteropServices;
using StarTools.Core.Apple;

namespace StarTools.Billing
{
    public static class Billing
    {
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void BillingRegisterProductIdentifier(string identifier);

        [DllImport("__Internal")]
        private static extern void BillingStart(IntPtr callback);

        public class StartResponse
        {
            public bool Success;
            public string Error;
        }
        
        public static void RegisterProductIdentifier(string identifier)
        {
            BillingRegisterProductIdentifier(identifier);
        }

        public static void Start(Action<StartResponse> onResponse)
        {
            BillingStart(Feedback.ActionToIntPtr(onResponse));
        }
    }
}
