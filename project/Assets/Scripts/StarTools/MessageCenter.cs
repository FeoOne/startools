using UnityEngine;

namespace StarTools
{
	using Platform;
	
	public static class MessageCenter
	{
		

		[RuntimeInitializeOnLoadMethod]
		private static void Setup()
		{
#if UNITY_IOS && (!STARTOOLS_DEBUG || !UNITY_EDITOR)
			Apple.MessageCenter.Setup(OnMessage);
#endif
#if UNITY_ANDROID && (!STARTOOLS_DEBUG || !UNITY_EDITOR)
			Google.MessageCenter.Setup(OnMessage);
#endif
		}

		private static void OnMessage(string message, string data)
		{
			
		}
	}
}
