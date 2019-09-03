using System;

namespace StarTools.Billing.Platform
{
    using Data;
    
    public interface IBillingContext
    {
        void RegisterLaunchSucceededFeedback(Action<LaunchSucceeded> action);
        void RegisterLaunchFailedFeedback(Action<LaunchFailed> action);
        void RegisterPurchaseSucceededFeedback(Action<PurchaseSucceeded> action);
        void RegisterPurchaseRestoredFeedback(Action<PurchaseRestored> action);
        void RegisterPurchaseFailedFeedback(Action<PurchaseFailed> action);
    }
}
