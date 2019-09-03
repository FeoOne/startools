using System;
using System.Runtime.InteropServices;
using StarTools.Core.Apple;

namespace StarTools.Billing.Platform.Apple
{
#if UNITY_IOS
    using Data;
    
    public sealed class BillingContext : BillingFacade, IBillingContext
    {
        // main
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_RegisterProduct([MarshalAs(UnmanagedType.LPStr)] string identifier, int type);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_Launch();
        [DllImport("__Internal", CharSet = CharSet.Ansi)]
        private static extern void StarTools_Billing_Purchase([MarshalAs(UnmanagedType.LPStr)] string identifier);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RestorePurchases();
        [DllImport("__Internal")]
        private static extern bool StarTools_Billing_CanMakePurchases();
        
        // feedback registration
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterLaunchSucceededFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterLaunchFailedFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseSucceededFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseRestoredFeedback(IntPtr action);
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterPurchaseFailedFeedback(IntPtr action);
        
        /**
         * Main
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

        public override void RestorePurchases()
        {
            StarTools_Billing_RestorePurchases();
        }

        public override bool CanMakePurchases()
        {
            return StarTools_Billing_CanMakePurchases();
        }
        
        /**
         * IFeedbackedbilling
         */
        
        public void RegisterLaunchSucceededFeedback(Action<LaunchSucceeded> action)
        {
            StarTools_Billing_RegisterLaunchSucceededFeedback(Feedback.ActionToIntPtr(action));
        }

        public void RegisterLaunchFailedFeedback(Action<LaunchFailed> action)
        {
            StarTools_Billing_RegisterLaunchFailedFeedback(Feedback.ActionToIntPtr(action));
        }

        public void RegisterPurchaseSucceededFeedback(Action<PurchaseSucceeded> action)
        {
            StarTools_Billing_RegisterPurchaseSucceededFeedback(Feedback.ActionToIntPtr(action));
        }
        
        public void RegisterPurchaseRestoredFeedback(Action<PurchaseRestored> action)
        {
            StarTools_Billing_RegisterPurchaseRestoredFeedback(Feedback.ActionToIntPtr(action));
        }

        public void RegisterPurchaseFailedFeedback(Action<PurchaseFailed> action)
        {
            StarTools_Billing_RegisterPurchaseFailedFeedback(Feedback.ActionToIntPtr(action));
        }
    }
#endif
}
