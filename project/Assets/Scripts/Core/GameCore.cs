using System;
using UnityEngine;
using StarTools.Billing;

namespace Core
{
    public class GameCore : MonoBehaviour
    {
        private IDisposable _launchSucceededHandle;
        private IDisposable _launchFailedHandle;
        
        private IDisposable _purchaseSucceededHandle;
        private IDisposable _purchaseRestoredHandle;
        private IDisposable _purchaseFailedHandle;
        
        private void Start()
        {
            Debug.Log($"Can make purchases: {Billing.Instance.CanMakePurchases()}");
            
            // launch succeeded
            _launchSucceededHandle = Billing.Instance.LaunchSucceededStream.Listen(x =>
            {
                _launchSucceededHandle.Dispose();
                _launchFailedHandle.Dispose();
            });
            
            // launch failed
            _launchFailedHandle = Billing.Instance.LaunchFailedStream.Listen(x =>
            {
                Debug.LogError($"Billing not launched ({x.Message})");
            });

            // purchase succeeded
            _purchaseSucceededHandle = Billing.Instance.PurchaseSucceededStream.Listen(x =>
            {
                Debug.Log($"Purchase succeeded {x.Identifier}");
            });

            // purchase restored
            _purchaseRestoredHandle = Billing.Instance.PurchaseRestoredStream.Listen(x =>
            {
                Debug.Log($"Purchase restored {x.Identifier}");
            });
            
            // purchase failed
            _purchaseFailedHandle = Billing.Instance.PurchaseFailedStream.Listen(x =>
            {
                Debug.Log($"Purchase failed {x.Message}");
                Debug.Log($"IsCancelled: {x.IsCancelled}");
                Debug.Log($"Code: {x.Code}");
            });
            
            
            Billing.Instance.RegisterProduct("com.samberdino.gameoflords.a_few_coins", BillingFacade.ProductType.Consumable);
            Billing.Instance.Launch();
        }

        private void OnDestroy()
        {
            _purchaseSucceededHandle.Dispose();
            _purchaseRestoredHandle.Dispose();
            _purchaseFailedHandle.Dispose();
        }

        public void OnPurchase()
        {
            Billing.Instance.Purchase("com.samberdino.gameoflords.a_few_coins");
        }
        
        public void OnRestore()
        {
            Billing.Instance.RestorePurchases();
        }
    }
}
