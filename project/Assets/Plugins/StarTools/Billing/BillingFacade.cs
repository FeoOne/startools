using System;

namespace StarTools.Billing
{
    using Data;
    
    public abstract class BillingFacade
    {
        public enum ProductType
        {
            Consumable = 1,
            NonConsumable = 2,
            Subscription = 4,
        }

        public abstract void RegisterProduct(string identifier, ProductType type);
        public abstract void Launch();
        public abstract void Purchase(string identifier);
        public abstract void RestorePurchases();
        public abstract bool CanMakePurchases();
    }
}
