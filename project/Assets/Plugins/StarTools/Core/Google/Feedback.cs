using System;
using UnityEngine;

namespace StarTools.Core.Google
{
    public static class Feedback
    {
        private class FeedbackHandler<T> : AndroidJavaProxy
        {
            private readonly Action<T> _action;
            
            public FeedbackHandler(Action<T> action) : base("com.feosoftware.startools.FeedbackHandler")
            {
                _action = action;
            }

            public void OnResponse(AndroidJavaObject result)
            {
                var json = result?.Call<string>("toString");
                var obj = Newtonsoft.Json.JsonConvert.DeserializeObject<T>(json);
                _action?.Invoke(obj);
            }
        }

        public static AndroidJavaProxy ActionToFeedback<T>(Action<T> action)
        {
            return new FeedbackHandler<T>(action);
        }
    }
}
