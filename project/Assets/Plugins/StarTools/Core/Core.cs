using UnityEngine;

namespace StarTools.Core
{
	public static class Core
	{
		[RuntimeInitializeOnLoadMethod]
		private static void Setup()
		{
			Debug.Log("StarTools.Core.Core.Setup()");
			
#if UNITY_IOS && (STARTOOLS_DEBUG || !UNITY_EDITOR)
			Apple.MessageCenter.Setup(OnMessage);
#endif
#if UNITY_ANDROID && (STARTOOLS_DEBUG || !UNITY_EDITOR)
			Google.Core.Setup();
			Google.MessageCenter.Setup(OnMessage);
#endif
		}

		private static void OnMessage(string message, string data)
		{
			// todo: process message from native code
		}
	}
}
