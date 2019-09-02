using System;

namespace StarTools.Billing
{
    using Data;
    
    public abstract class AbstractBilling
    {
        public enum ProductType
        {
            Consumable = 0,
            NonConsumable = 1,
            Subscription = 2,
        }

        public abstract void RegisterProduct(string identifier, ProductType type);
        
        public abstract void Launch();

        public abstract void Purchase(string identifier);

        public virtual void RegisterLaunchSucceededFeedback(Action<LaunchSucceeded> action) { }
        public virtual void RegisterLaunchFailedFeedback(Action<LaunchFailed> action) { }
        public virtual void RegisterPurchaseSucceededFeedback(Action<PurchaseSucceeded> action) { }
        public virtual void RegisterPurchaseFailedFeedback(Action<PurchaseFailed> action) { }
        public virtual void RegisterPurchaseRestoredFeedback(Action<PurchaseRestored> action) { }
    }
}
