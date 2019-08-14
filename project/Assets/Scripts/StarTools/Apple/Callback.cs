using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace StarTools.Apple
{
    public class Callback
    {
        private delegate void CallbackDelegate(IntPtr ptr, string data);

        [DllImport("__Internal")]
        private static extern void RegisterCallbackDelegate(CallbackDelegate callbackDelegate);

        [AOT.MonoPInvokeCallback(typeof(CallbackDelegate))]
        private static void CallbackInvoke(IntPtr ptr, string data)
        {
            if (IntPtr.Zero.Equals(ptr))
            {
                return;
            }

            var action = IntPtrToObject(ptr, true);
            if (action == null)
            {
                Debug.LogError("Missed callback.");
                return;
            }

            try
            {
                object arg;
                Type[] methodTypes;
                object[] parameters;
                
                var types = action.GetType().GetGenericArguments();
                if (types.Length == 0)
                {
                    arg = null;
                    methodTypes = new Type[0];
                    parameters = new object[] { };
                }
                else
                {
                    arg = ConvertObject(data, types[0]);
                    methodTypes = new[] { types[0] };
                    parameters = new[] { arg };
                }
                
                var method = action.GetType().GetMethod("Invoke", methodTypes);
                if (method != null)
                {
                    method.Invoke(action, parameters);
                }
                else
                {
                    Debug.LogError($"Failed to invoke callback {action} with arg {arg}: invoke method not found.");
                }
            }
            catch (Exception exception)
            {
                Debug.LogError($"Failed to invoke callback {action} with arg {data}: {exception}");
            }
        }

        private static object IntPtrToObject(IntPtr ptr, bool needUnpin)
        {
            if (IntPtr.Zero.Equals(ptr))
            {
                return null;
            }

            var handle = GCHandle.FromIntPtr(ptr);
            var result = handle.Target;
            if (needUnpin)
            {
                handle.Free();
            }

            return result;
        }

        private static object ConvertObject(string value, Type type)
        {
            if (value == null || type == typeof(string))
            {
                return value;
            }

            return Newtonsoft.Json.JsonConvert.DeserializeObject(value, type);
        }

        [RuntimeInitializeOnLoadMethod]
        private static void Setup()
        {
            RegisterCallbackDelegate(CallbackInvoke);
        }
    }
}