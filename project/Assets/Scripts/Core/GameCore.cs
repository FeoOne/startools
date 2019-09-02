using System;
using UnityEngine;
using StarTools.Billing;

namespace Core
{
    public class GameCore : MonoBehaviour
    {
        private IDisposable _launchSucceededHandle;
        private IDisposable _launchFailedHandle;
        
        private void Start()
        {
            _launchSucceededHandle = Billing.Instance.LaunchSucceededStream.Listen(x =>
            {
                _launchSucceededHandle.Dispose();
                _launchFailedHandle.Dispose();
                
                Billing.Instance.Purchase("com.samberdino.gameoflords.a_few_coins");
            });
            _launchFailedHandle = Billing.Instance.LaunchFailedStream.Listen(x => { Debug.LogError($"Billing not launched ({x.Message})"); });
            
            Billing.Instance.RegisterProduct("com.samberdino.gameoflords.a_few_coins", AbstractBilling.ProductType.Consumable);
            Billing.Instance.Launch();
        }
        
        
    }
}
