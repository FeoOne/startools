using StarTools.Billing.Data;
using UnityEngine;

#if !STARTOOLS_DEBUG
#   undef UNITY_ASSERTIONS
#endif

namespace StarTools.Billing.Platform
{
    public class Product
    {
        private readonly ProductMetadata _metadata;

        public string Identifier => _metadata.Identifier;
        public string Description => _metadata.LocalizedDescription;
        public string Title => _metadata.LocalizedTitle;
        public string Price => _metadata.LocalizedPrice;
        
        public Product(ProductMetadata metadata)
        {
            Debug.Assert(metadata != null);
            
            _metadata = metadata;
        }
    }
}
