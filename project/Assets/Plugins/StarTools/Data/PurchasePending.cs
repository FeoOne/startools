namespace StarTools.Data
{
#if UNITY_ANDROID
    public class PurchasePending
    {
        public string Token;
        public string Receipt;
        public string Signature;
        public string CurrencyCode;
        public float Price;
    }
#endif
}
