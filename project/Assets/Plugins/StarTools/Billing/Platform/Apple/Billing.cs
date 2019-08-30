using System;
using System.Runtime.InteropServices;
using StarTools.Core.Apple;

namespace StarTools.Billing.Platform.Apple
{
    public sealed class Billing : AbstractBilling
    {
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_RegisterProduct(string identifier, int type);

        [DllImport("__Internal")]
        private static extern void StarTools_Billing_Launch(IntPtr onSuccessCallback, IntPtr onFailCallback);
        
        public override void RegisterProduct(string identifier, ProductType type)
        {
            StarTools_Billing_RegisterProduct(identifier, (int)type);
        }

        public override void Launch(Action<Data.LaunchSucceeded> onSuccess, Action<Data.LaunchFailed> onFail)
        {
            StarTools_Billing_Launch(Feedback.ActionToIntPtr(onSuccess), Feedback.ActionToIntPtr(onFail));
        }
    }
}
