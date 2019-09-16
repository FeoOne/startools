using System;
using System.Collections.Generic;
using UnityEngine;
using StarTools.Billing;
using StarTools.Billing.Data;
using StarTools.Billing.Platform;
using UnityEngine.Serialization;
using UnityEngine.UI;

namespace Core
{
    public class GameCore : MonoBehaviour
    {
        [FormerlySerializedAs("Lock Label")] [SerializeField] private Text lockLabel;
        [FormerlySerializedAs("Purchase Label")] [SerializeField] private Text purchaseLabel;
        
        private IDisposable _launchSucceededHandle;
        private IDisposable _launchFailedHandle;
        
        private IDisposable _purchaseSucceededHandle;
        private IDisposable _purchaseRestoredHandle;
        private IDisposable _purchaseFailedHandle;

        private void Awake()
        {
            Application.SetStackTraceLogType(LogType.Log, StackTraceLogType.None);
        }

        private void Start()
        {
            Debug.Log($"Can make purchases: {Billing.Instance.CanMakePurchases()}");
            
            // launch succeeded
            _launchSucceededHandle = Billing.Instance.LaunchSucceededStream.Listen(x =>
            {
                UnlockInterface();
                
                _launchSucceededHandle.Dispose();
                _launchFailedHandle.Dispose();
            });
            
            // launch failed
            _launchFailedHandle = Billing.Instance.LaunchFailedStream.Listen(x =>
            {
                UnlockInterface();
                
                Debug.LogError($"Billing not launched ({x.Message})");
            });

            // purchase succeeded
            _purchaseSucceededHandle = Billing.Instance.PurchaseSucceededStream.Listen(x =>
            {
                purchaseLabel.text = $"Purchased {Billing.Instance.Products[x.Identifier].Title}";
                
                UnlockInterface();
                
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
                purchaseLabel.text = "purchase failed";
                
                UnlockInterface();
                
                Debug.Log($"Purchase failed {x.Message}");
                Debug.Log($"IsCancelled: {x.IsCancelled}");
                Debug.Log($"Code: {x.Code}");
            });
            
            Billing.Instance.RegisterProduct("com.samberdino.gameoflords.a_few_coins", BillingFacade.ProductType.Consumable);
            
            LockInterface();
            
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
            purchaseLabel.text = "no data";
            
            LockInterface();
            
            Billing.Instance.Purchase("com.samberdino.gameoflords.a_few_coins");
        }
        
        public void OnRestore()
        {
            Billing.Instance.RestorePurchases();
        }

        private void LockInterface()
        {
            lockLabel.text = "locked";
        }
        
        private void UnlockInterface()
        {
            lockLabel.text = "unlocked";
        }
    }
}
