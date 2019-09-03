using System;
using UnityEngine;
using StarTools.Core;
using StarTools.Core.Google;

namespace StarTools.Billing.Platform.Google
{
#if UNITY_ANDROID
    public sealed class BillingContext : BillingFacade, IFeedbacked
    {
        private readonly AndroidJavaObject _billing;

        public BillingContext()
        {
            _billing = new AndroidJavaObject("com.feosoftware.startools.billing.Billing");
        }
        
        public override void RegisterProduct(string identifier, ProductType type)
        {
            _billing?.Call("registerProduct", identifier, (int)type);
        }

        public override void Launch()
        {
            _billing?.Call("launch");
        }
        
        public override void Purchase(string identifier)
        {
            _billing?.Call("purchase", identifier);
        }
        
        public override void RestorePurchases()
        {
            // todo: implement
        }
        
        public override bool CanMakePurchases()
        {
            return true;
        }
        
        /**
         * IFeedbacked
         */
        
        public void RegisterFeedback<T>(int key, Action<T> action)
        {
            _billing?.Call("registerFeedback", key, Feedback.ActionToFeedback(action));
        }
    }
#endif
}
