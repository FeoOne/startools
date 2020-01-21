using System;
using System.Runtime.InteropServices;
using UnityEngine;

#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR) // apple
using StarTools.Core.Apple;
#endif

#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR) // google
using StarTools.Core.Google;
#endif

namespace StarTools.Core
{
    public static class FeedbackHelper
    {
        public enum Key {
            LaunchSucceeded = 0,
            LaunchFailed = 1,
            PurchaseSucceeded = 2,
            PurchaseRestored = 3,
            PurchaseFailed = 4,
            NetworkStateChanged = 5,
#if UNITY_ANDROID
            PurchasePending = 6,
#endif
        }
            
#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR) // apple
        [DllImport("__Internal")]
        private static extern void StarTools_Billing_RegisterFeedback(int key, IntPtr action);
#endif
        
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR) // google
        private static readonly AndroidJavaObject FeedbackHelperClass;
#endif

        static FeedbackHelper()
        {
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR) // google
            FeedbackHelperClass = new AndroidJavaClass("com.feosoftware.startools.core.FeedbackHelper");
#endif
        }
        
        public static void RegisterFeedback<T>(int key, Action<T> action)
        {
#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR) // apple
            StarTools_Billing_RegisterFeedback(key, Feedback.ActionToIntPtr(action));
#endif
            
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR) // google
            FeedbackHelperClass.CallStatic("registerFeedback", key, Feedback.ActionToFeedback(action));
#endif
        }
    }
}
