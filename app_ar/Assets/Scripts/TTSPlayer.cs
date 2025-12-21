using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using System.Text;

public class TTSPlayer : MonoBehaviour
{
    public AudioSource audioSource;
    public string googleApiKey = Constants.API_KEY;

    public bool IsSpeaking => audioSource.isPlaying;

    public void Speak(string text)
    {
        StartCoroutine(TextToSpeech(text));
    }

    IEnumerator TextToSpeech(string text)
    {
        string json = $@"
        {{
          ""input"": {{ ""text"": ""{text}"" }},
          ""voice"": {{
            ""languageCode"": ""vi-VN"",
            ""name"": ""vi-VN-Neural2-A""
          }},
          ""audioConfig"": {{
            ""audioEncoding"": ""LINEAR16""
          }}
        }}";

        UnityWebRequest req = new UnityWebRequest(
            $"https://texttospeech.googleapis.com/v1/text:synthesize?key={googleApiKey}",
            "POST"
        );

        req.uploadHandler = new UploadHandlerRaw(Encoding.UTF8.GetBytes(json));
        req.downloadHandler = new DownloadHandlerAudioClip("tts.wav", AudioType.WAV);
        req.SetRequestHeader("Content-Type", "application/json");

        yield return req.SendWebRequest();

        if (req.result == UnityWebRequest.Result.Success)
        {
            audioSource.clip = DownloadHandlerAudioClip.GetContent(req);
            audioSource.Play();
        }
        else
        {
            Debug.LogError(req.error);
        }
    }
}
