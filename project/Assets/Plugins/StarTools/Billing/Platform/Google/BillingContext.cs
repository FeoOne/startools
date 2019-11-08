using System;
using UnityEngine;
using StarTools.Core;

namespace StarTools.Billing.Platform.Google
{
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    using Core.Google;

    public sealed class BillingContext : BillingFacade
    {
        private readonly AndroidJavaObject _object;

        public BillingContext()
        {
            _object = new AndroidJavaObject("com.feosoftware.startools.billing.Billing");
        }
        
        /**
         * BillingFacade
         */

        public override void RegisterProduct(string identifier, ProductType type)
        {
            _object?.Call("registerProduct", identifier, (int)type);
        }

        public override void Launch()
        {
            _object?.Call("launch");
        }
        
        public override void Purchase(string identifier)
        {
            _object?.Call("purchase", identifier);
        }
        
        public override void RestorePurchases()
        {
            _object?.Call("restorePurchases");
        }
        
        public override bool CanMakePurchases()
        {
            return true;
        }
    }
#endif
}
