using UnityEngine;
using System.Collections;
using UnityEngine.Networking;
using System.Text;

public class VoiceRecorder : MonoBehaviour
{
    public float recordSeconds = 4f;
    public int sampleRate = 16000;
    public string googleApiKey = Constants.API_KEY;

    public TTSPlayer tts;
    public ChatClient chat;

    void Start()
    {
        Debug.Log("Checking microphone devices...");
        Debug.Log(Microphone);
        foreach (var device in Microphone.devices)
            Debug.Log("Mic device found: " + device);

        if (Microphone.devices.Length > 0)
        {
            Debug.Log("Starting recording...");
            AudioClip clip = Microphone.Start(Microphone.devices[0], true, 10, 44100);
        }
        else
        {
            Debug.LogWarning("No microphone devices found! Will retry in 1s.");
            StartCoroutine(RetryMicrophone());
        }

        StartCoroutine(ListenLoop());
    }

    IEnumerator RetryMicrophone()
    {
        yield return new WaitForSeconds(5f);
        Start();
    }

    IEnumerator ListenLoop()
    {
        while (true)
        {
            if (tts != null && tts.IsSpeaking)
            {
                yield return null;
                continue;
            }

            Debug.Log("Starting recording...");
            AudioClip clip = Microphone.Start(null, false, (int)recordSeconds, sampleRate);

            yield return new WaitForSeconds(0.5f);
            if (Microphone.devices.Length == 0)
            {
                Debug.LogError("No microphone devices found!");
                yield break;
            }
            Debug.Log("Detected mic: " + Microphone.devices[0]);
            foreach (var dev in Microphone.devices)
            {
                Debug.Log("Detected mic: " + dev);
            }

            // Chờ Microphone ghi âm xong
            yield return new WaitForSeconds(recordSeconds);

            if (clip == null)
            {
                Debug.LogError("Microphone.Start returned null!");
                yield return new WaitForSeconds(1f);
                continue;
            }

            Microphone.End(null);
            Debug.Log($"Recorded clip: length={clip.length}s, frequency={clip.frequency}Hz");

            byte[] wav = null;
            bool wavFailed = false;

            try
            {
                wav = WavUtility.FromAudioClip(clip);
                Debug.Log($"WAV byte length: {wav.Length}");
            }
            catch (System.Exception ex)
            {
                Debug.LogError("WavUtility.FromAudioClip failed: " + ex.Message);
                wavFailed = true;
            }
            if (wavFailed)
            {
                yield return new WaitForSeconds(1f);
                continue;
            }

            yield return SpeechToText(wav);
            yield return new WaitForSeconds(0.3f);
        }
    }

    IEnumerator SpeechToText(byte[] wav)
    {
        if (wav == null || wav.Length == 0)
        {
            Debug.LogError("WAV data is null or empty!");
            yield break;
        }

        string base64 = System.Convert.ToBase64String(wav);
        string json = $@"
        {{
          ""config"": {{
            ""encoding"": ""LINEAR16"",
            ""languageCode"": ""vi-VN""
          }},
          ""audio"": {{
            ""content"": ""{base64}""
          }}
        }}";

        UnityWebRequest req = new UnityWebRequest(
            $"https://speech.googleapis.com/v1/speech:recognize?key={googleApiKey}",
            "POST"
        );

        req.uploadHandler = new UploadHandlerRaw(Encoding.UTF8.GetBytes(json));
        req.downloadHandler = new DownloadHandlerBuffer();
        req.SetRequestHeader("Content-Type", "application/json");

        yield return req.SendWebRequest();

        if (req.result == UnityWebRequest.Result.Success)
        {
            Debug.Log("Speech-to-Text response: " + req.downloadHandler.text);
            SpeechRes res = JsonUtility.FromJson<SpeechRes>(req.downloadHandler.text);

            if (res.results != null && res.results.Length > 0)
            {
                string text = res.results[0].alternatives[0].transcript;
                Debug.Log("Recognized text: " + text);
                if (!string.IsNullOrEmpty(text) && chat != null)
                {
                    chat.Send(text);
                }
            }
        }
        else
        {
            Debug.LogError("Speech-to-Text request error: " + req.error);
        }
    }

    [System.Serializable]
    public class SpeechRes
    {
        public Result[] results;
    }

    [System.Serializable]
    public class Result
    {
        public Alternative[] alternatives;
    }

    [System.Serializable]
    public class Alternative
    {
        public string transcript;
    }
}
