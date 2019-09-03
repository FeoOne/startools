using System;
using UnityEngine;
using StarTools.Event;
using StarTools.Billing.Data;
using StarTools.Billing.Platform.Apple;
#if UNITY_IOS

#elif UNITY_ANDROID
using BillingContext = StarTools.Billing.Platform.Google.Billing;
#endif

namespace StarTools.Billing
{
    public class Billing : BillingFacade
    {
        private static BillingContext _billing;

        public static Billing Instance { get; private set; }

        public readonly Stream<LaunchSucceeded> LaunchSucceededStream = new Stream<LaunchSucceeded>();
        public readonly Stream<LaunchFailed> LaunchFailedStream = new Stream<LaunchFailed>();
        public readonly Stream<PurchaseSucceeded> PurchaseSucceededStream = new Stream<PurchaseSucceeded>();
        public readonly Stream<PurchaseRestored> PurchaseRestoredStream = new Stream<PurchaseRestored>();
        public readonly Stream<PurchaseFailed> PurchaseFailedStream = new Stream<PurchaseFailed>();

        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            _billing = new BillingContext();
            
            Instance = new Billing();
            Instance.RegisterFeedbacks();
        }
        
        private Billing()
        {
            Debug.Log("Billing started up.");
        }

        public override void RegisterProduct(string identifier, ProductType type)
        {
            Debug.Assert(_billing != null, "Billing not initialized.");
            Debug.Assert(!string.IsNullOrWhiteSpace(identifier), "Identifier must be specified.");
            _billing?.RegisterProduct(identifier, type);
        }

        public override void Launch()
        {
            Debug.Assert(_billing != null, "Billing not initialized.");
            _billing?.Launch();
        }

        public override void Purchase(string identifier)
        {
            Debug.Assert(!string.IsNullOrWhiteSpace(identifier), "Identifier must be specified.");
            _billing?.Purchase(identifier);
        }

        public override void RestorePurchases()
        {
            _billing?.RestorePurchases();
        }

        public override bool CanMakePurchases()
        {
            return _billing?.CanMakePurchases() ?? false;
        }

        private void RegisterFeedbacks()
        {
            _billing?.RegisterLaunchSucceededFeedback(x => LaunchSucceededStream.Send(x));
            _billing?.RegisterLaunchFailedFeedback(x => LaunchFailedStream.Send(x));
            _billing?.RegisterPurchaseSucceededFeedback(x => PurchaseSucceededStream.Send(x));
            _billing?.RegisterPurchaseFailedFeedback(x => PurchaseFailedStream.Send(x));
            _billing?.RegisterPurchaseRestoredFeedback(x => PurchaseRestoredStream.Send(x));
        }
    }
}
