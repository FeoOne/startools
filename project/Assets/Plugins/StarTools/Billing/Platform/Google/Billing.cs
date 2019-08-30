using System;
using StarTools.Core.Google;
using UnityEngine;

namespace StarTools.Billing.Platform.Google
{
    public sealed class Billing : AbstractBilling
    {
        private readonly AndroidJavaObject _billing;

        public Billing()
        {
            _billing = new AndroidJavaObject("com.feosoftware.startools.billing.Billing");
        }
        
        public override void RegisterProduct(string identifier, ProductType type)
        {
            _billing?.Call("registerProduct", identifier, (int)type);
        }

        public override void Launch(Action<Data.LaunchSucceeded> onSuccess, Action<Data.LaunchFailed> onFail)
        {
            _billing?.Call("launch", Feedback.ActionToFeedback(onSuccess), Feedback.ActionToFeedback(onFail));
        }
    }
}
