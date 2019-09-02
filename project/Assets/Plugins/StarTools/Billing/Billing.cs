using System;
using UnityEngine;
using StarTools.Event;
using StarTools.Billing.Data;

namespace StarTools.Billing
{
    public class Billing : AbstractBilling
    {
        private static AbstractBilling _billing;

        public static Billing Instance { get; private set; }

        public readonly Stream<LaunchSucceeded> LaunchSucceededStream = new Stream<LaunchSucceeded>();
        public readonly Stream<LaunchFailed> LaunchFailedStream = new Stream<LaunchFailed>();
        public readonly Stream<PurchaseSucceeded> PurchaseSucceededStream = new Stream<PurchaseSucceeded>();
        public readonly Stream<PurchaseFailed> PurchaseFailedStream = new Stream<PurchaseFailed>();
        public readonly Stream<PurchaseRestored> PurchaseRestoredStream = new Stream<PurchaseRestored>();

        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            Instance = new Billing();
            
#if !STARTOOLS_DEBUG || !UNITY_EDITOR
#   if UNITY_IOS
            _billing = new Platform.Apple.Billing();
#   elif UNITY_ANDROID
			_billing = new Platform.Google.Billing();
#   endif
#else
            // todo: stub
#endif

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
