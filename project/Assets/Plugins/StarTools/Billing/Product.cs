using StarTools.Billing.Data;

namespace StarTools.Billing.Platform
{
    public class Product
    {
        private readonly ProductMetadata _metadata;
        
        public Product(ProductMetadata metadata)
        {
            _metadata = metadata;
        }
    }
}
