using System;

namespace StarTools.Billing
{
    public abstract class AbstractBilling
    {
        public enum ProductType
        {
            Consumable = 0,
            NonConsumable = 1,
        }
        
        public abstract void RegisterProduct(string identifier, ProductType type);
        
        public abstract void Launch(Action<Data.LaunchSucceeded> onSuccess, Action<Data.LaunchFailed> onFail);
    }
}
