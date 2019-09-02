using System;
using System.Runtime.InteropServices;
using StarTools.Core.Apple;

namespace StarTools.Billing.Platform.Apple
{
#if UNITY_IOS
    using Data;
    
    public sealed class Billing : AbstractBilling
    {
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_RegisterProduct([MarshalAs(UnmanagedType.LPStr)] string identifier, int type);

        [DllImport("__Internal")]
        private static extern void StarTools_Billing_Launch();
        
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_Purchase([MarshalAs(UnmanagedType.LPStr)] string identifier);
        
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterLaunchSucceededFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterLaunchFailedFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseSucceededFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseFailedFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseRestoredFeedback(IntPtr action);
        
        /**
         * Facade
         */
        
        public override void RegisterProduct(string identifier, ProductType type)
        {
            StarTools_Billing_RegisterProduct(identifier, (int)type);
        }

        public override void Launch()
        {
            StarTools_Billing_Launch();
        }

        public override void Purchase(string identifier)
        {
            StarTools_Billing_Purchase(identifier);
        }

        /**
         * Feedbacks.
         */
        
        public override void RegisterLaunchSucceededFeedback(Action<LaunchSucceeded> action)
        {
            StarTools_Billing_RegisterLaunchSucceededFeedback(Feedback.ActionToIntPtr(action));
        }

        public override void RegisterLaunchFailedFeedback(Action<LaunchFailed> action)
        {
            StarTools_Billing_RegisterLaunchFailedFeedback(Feedback.ActionToIntPtr(action));
        }

        public override void RegisterPurchaseSucceededFeedback(Action<PurchaseSucceeded> action)
        {
            StarTools_Billing_RegisterPurchaseSucceededFeedback(Feedback.ActionToIntPtr(action));
        }

        public override void RegisterPurchaseFailedFeedback(Action<PurchaseFailed> action)
        {
            StarTools_Billing_RegisterPurchaseFailedFeedback(Feedback.ActionToIntPtr(action));
        }
        
        public override void RegisterPurchaseRestoredFeedback(Action<PurchaseRestored> action)
        {
            StarTools_Billing_RegisterPurchaseRestoredFeedback(Feedback.ActionToIntPtr(action));
        }
    }
#endif
}
