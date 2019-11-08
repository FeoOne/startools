using StarTools.Billing.Data;
using StarTools.Event;
using UnityEngine;

namespace StarTools.Core
{
    public class Network
    {
        public static Network Instance { get; private set; }
        
        public readonly Stream<LaunchSucceeded> NetworkStateChangedStream = new Stream<LaunchSucceeded>();
        
        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            Instance = new Network();
            Instance.RegisterFeedbacks();
        }

        private void RegisterFeedbacks()
        {
            FeedbackHelper.RegisterFeedback<LaunchSucceeded>((int) FeedbackHelper.Key.NetworkStateChanged,
                x => NetworkStateChangedStream.Send(x));
        }
    }
}
