using System;
using UnityEngine;

namespace StarTools.Billing
{
    public class Billing : AbstractBilling
    {
        private static Billing _instance;
        private static AbstractBilling _billing;

        public static Billing Instance => _instance;
        
        private Billing() { }

        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            _instance = new Billing();
            
#if !STARTOOLS_DEBUG || !UNITY_EDITOR
#   if UNITY_IOS
            _billing = new Platform.Apple.Billing();
#   elif UNITY_ANDROID
			_billing = new Platform.Google.Billing();
#   endif
#else
            // todo: stub
#endif
        }

        public override void RegisterProduct(string identifier, ProductType type)
        {
            _billing?.RegisterProduct(identifier, type);
        }

        public override void Launch(Action<Data.LaunchSucceeded> onSuccess, Action<Data.LaunchFailed> onFail)
        {
            _billing?.Launch(onSuccess, onFail);
        }
    }
}
