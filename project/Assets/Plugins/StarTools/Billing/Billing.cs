using UnityEngine;

namespace StarTools.Billing
{
    using Data;
    using Event;
    
#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    using Platform.Apple;
#elif UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    using Platform.Google;
#else
    using Platform.Stub;
#endif
    
    public class Billing : BillingFacade
    {
        private enum FeedbackKey {
            LaunchSucceeded = 0,
            LaunchFailed = 1,
            PurchaseSucceeded = 2,
            PurchaseRestored = 3,
            PurchaseFailed = 4,
        };
        
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
            _billing?.RegisterFeedback<LaunchSucceeded>((int)FeedbackKey.LaunchSucceeded, 
                x => LaunchSucceededStream.Send(x));
            _billing?.RegisterFeedback<LaunchFailed>((int)FeedbackKey.LaunchFailed, 
                x => LaunchFailedStream.Send(x));
            _billing?.RegisterFeedback<PurchaseSucceeded>((int)FeedbackKey.PurchaseSucceeded, 
                x => PurchaseSucceededStream.Send(x));
            _billing?.RegisterFeedback<PurchaseRestored>((int)FeedbackKey.PurchaseRestored, 
                x => PurchaseRestoredStream.Send(x));
            _billing?.RegisterFeedback<PurchaseFailed>((int)FeedbackKey.PurchaseFailed, 
                x => PurchaseFailedStream.Send(x));
        }
    }
}
