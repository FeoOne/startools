using System;
using StarTools.Core.Google;
using UnityEngine;

namespace StarTools.Billing.Platform.Google
{
#if UNITY_ANDROID
    public sealed class Billing : AbstractBilling
    {
        private readonly AndroidJavaObject _billing;

        public Billing()
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
            
        }
        
        /**
         * Feedbacks.
         */
        
        public override void RegisterLaunchSucceededFeedback(Action<Data.LaunchSucceeded> action)
        {
            
        }

        public override void RegisterLaunchFailedFeedback(Action<Data.LaunchFailed> action)
        {
            
        }

        public override void RegisterPurchaseSucceededFeedback(Action<Data.PurchaseSucceeded> action)
        {
            
        }

        public override void RegisterPurchaseFailedFeedback(Action<Data.PurchaseFailed> action)
        {
            
        }
    }
#endif
}
