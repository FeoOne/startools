using UnityEngine;

namespace StarTools
{
	public static class MessageHandler
	{
		[RuntimeInitializeOnLoadMethod]
		private static void Setup()
		{
#if UNITY_IOS //&& !UNITY_EDITOR
			Apple.MessageHandler.Setup();
#endif
#if UNITY_ANDROID //&& !UNITY_EDITOR
			Google.MessageHandler.Setup();
#endif
		}
	}
}
