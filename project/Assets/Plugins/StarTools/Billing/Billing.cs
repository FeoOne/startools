#if !STARTOOLS_DEBUG
#   undef UNITY_ASSERTIONS
#endif

using System;
using System.Collections.Generic;
using StarTools.Core;
using UnityEngine;

namespace StarTools.Billing
{
    using Data;
    using Event;
    using Platform;
    
#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    using Platform.Apple;
#elif UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
    using Platform.Google;
#else
    using Platform.Stub;
#endif
    
    public class Billing : BillingFacade
    {
        private static BillingContext _billing;

        public static Billing Instance { get; private set; }

        public IDictionary<string, Product> Products { get; } = new Dictionary<string, Product>();

        public readonly Stream<LaunchSucceeded> LaunchSucceededStream = new Stream<LaunchSucceeded>();
        public readonly Stream<LaunchFailed> LaunchFailedStream = new Stream<LaunchFailed>();
        public readonly Stream<PurchaseSucceeded> PurchaseSucceededStream = new Stream<PurchaseSucceeded>();
        public readonly Stream<PurchaseRestored> PurchaseRestoredStream = new Stream<PurchaseRestored>();
        public readonly Stream<PurchaseFailed> PurchaseFailedStream = new Stream<PurchaseFailed>();
        
        private IDisposable _launchSucceededHandle;
        private IDisposable _launchFailedHandle;

        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            _billing = new BillingContext();
            
            Instance = new Billing();
            Instance.RegisterFeedbacks();
            Instance.ListenLaunchResult();
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
            FeedbackHelper.RegisterFeedback<LaunchSucceeded>((int)FeedbackHelper.Key.LaunchSucceeded, 
                x => LaunchSucceededStream.Send(x));
            FeedbackHelper.RegisterFeedback<LaunchFailed>((int)FeedbackHelper.Key.LaunchFailed, 
                x => LaunchFailedStream.Send(x));
            FeedbackHelper.RegisterFeedback<PurchaseSucceeded>((int)FeedbackHelper.Key.PurchaseSucceeded, 
                x => PurchaseSucceededStream.Send(x));
            FeedbackHelper.RegisterFeedback<PurchaseRestored>((int)FeedbackHelper.Key.PurchaseRestored, 
                x => PurchaseRestoredStream.Send(x));
            FeedbackHelper.RegisterFeedback<PurchaseFailed>((int)FeedbackHelper.Key.PurchaseFailed, 
                x => PurchaseFailedStream.Send(x));
        }

        private void ListenLaunchResult()
        {
            _launchSucceededHandle = LaunchSucceededStream.Listen(OnLaunchSucceeded);
            _launchFailedHandle = LaunchFailedStream.Listen(OnLaunchFailed);
        }

        private void OnLaunchSucceeded(LaunchSucceeded response)
        {
            foreach (var metadata in response.Products)
            {
                Products.Add(metadata.Identifier, new Product(metadata));
            }
        }

        private void OnLaunchFailed(LaunchFailed response)
        {
            // todo
        }
    }
}
