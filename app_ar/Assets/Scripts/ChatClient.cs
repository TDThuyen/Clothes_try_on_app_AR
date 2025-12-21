using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using System.Text;

public class ChatClient : MonoBehaviour
{
    public string serverUrl = Constants.SERVER_URL;
    public TTSPlayer tts;

    public void Send(string text)
    {
        StartCoroutine(Post(text));
    }

    IEnumerator Post(string text)
    {
        ChatReq reqBody = new ChatReq { message = text };
        string json = JsonUtility.ToJson(reqBody);

        UnityWebRequest req = new UnityWebRequest(serverUrl, "POST");
        req.uploadHandler = new UploadHandlerRaw(Encoding.UTF8.GetBytes(json));
        req.downloadHandler = new DownloadHandlerBuffer();
        req.SetRequestHeader("Content-Type", "application/json");

        yield return req.SendWebRequest();

        if (req.result == UnityWebRequest.Result.Success)
        {
            ChatRes res = JsonUtility.FromJson<ChatRes>(req.downloadHandler.text);
            if (!string.IsNullOrEmpty(res.reply))
            {
                tts.Speak(res.reply);
            }
        }
        else
        {
            Debug.LogError(req.error);
        }
    }

    [System.Serializable]
    class ChatReq
    {
        public string message;
    }

    [System.Serializable]
    class ChatRes
    {
        public string reply;
    }
}
