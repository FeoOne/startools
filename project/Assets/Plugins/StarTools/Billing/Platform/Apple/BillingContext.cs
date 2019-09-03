using System;
using System.Runtime.InteropServices;
using StarTools.Core;
using StarTools.Core.Apple;

namespace StarTools.Billing.Platform.Apple
{
#if UNITY_IOS
    using Data;
    
    public sealed class BillingContext : BillingFacade, IFeedbacked
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
        private static extern void StarTools_Billing_RegisterFeedback(int key, IntPtr action);

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
         * IFeedbacked
         */
        
        public void RegisterFeedback<T>(int key, Action<T> action)
        {
            StarTools_Billing_RegisterFeedback(key, Feedback.ActionToIntPtr(action));
        }
    }
#endif
}