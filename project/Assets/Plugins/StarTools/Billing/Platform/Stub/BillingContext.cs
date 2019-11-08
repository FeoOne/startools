using System;
using UnityEngine;
using StarTools.Core;

namespace StarTools.Billing.Platform.Stub
{
    public sealed class BillingContext : BillingFacade
    {
        /**
         * BillingFacade
         */
        
        public override void RegisterProduct(string identifier, ProductType type)
        {
            //
        }

        public override void Launch()
        {
            //
        }
        
        public override void Purchase(string identifier)
        {
            //
        }
        
        public override void RestorePurchases()
        {
            //
        }
        
        public override bool CanMakePurchases()
        {
            return false;
        }
        
        /**
         * IFeedbacked
         */
        
        public void RegisterFeedback<T>(int key, Action<T> action)
        {
            //
        }
    }
}
