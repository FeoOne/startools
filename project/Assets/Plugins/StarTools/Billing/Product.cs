#if !STARTOOLS_DEBUG
#   undef UNITY_ASSERTIONS
#endif

using StarTools.Billing.Data;
using UnityEngine;

namespace StarTools.Billing.Platform
{
    public class Product
    {
        private readonly ProductMetadata _metadata;

        public string Identifier => _metadata.Identifier;
        public string Description => _metadata.LocalizedDescription;
        public string Title => _metadata.LocalizedTitle;
        public string LocalizedPrice => _metadata.LocalizedPrice;
        public string CurrencyCode => _metadata.CurrencyCode;
        public float Price => _metadata.Price;
        
        
        public Product(ProductMetadata metadata)
        {
            Debug.Assert(metadata != null);
            
            _metadata = metadata;
        }
    }
}
