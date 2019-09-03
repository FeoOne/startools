using System;

namespace StarTools.Core
{
    public interface IFeedbacked
    {
        void RegisterFeedback<T>(int key, Action<T> action);
    }
}
