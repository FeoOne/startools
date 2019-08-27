using System;
using System.Runtime.InteropServices;
using StarTools.Core.Apple;

namespace StarTools.Billing
{
    public static class Billing
    {
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_RegisterProductIdentifier(string identifier);

        [DllImport("__Internal")]
        private static extern void StarTools_Billing_Launch(IntPtr onSuccessCallback, IntPtr onFailCallback);

        public static void RegisterProductIdentifier(string identifier)
        {
            StarTools_Billing_RegisterProductIdentifier(identifier);
        }

        public static void Launch(Action<Response.StartSuccess> onSuccess, Action<Response.StartFail> onFail)
        {
            StarTools_Billing_Launch(Feedback.ActionToIntPtr(onSuccess), Feedback.ActionToIntPtr(onFail));
        }
    }
}
